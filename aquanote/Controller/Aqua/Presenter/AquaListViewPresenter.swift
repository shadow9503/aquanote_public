//
//  AquaListViewPresenter.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/14.
//

import UIKit

enum AquaListViewRowType: Int {
    case aqua = 0
    case searchterm = 1
    case loading = 2
    case noResult = 3
}

protocol AquaListViewDelegate: AnyObject, ViewableProtocol {
    func didSuccessFetch()
    func didFailedFetch()
    func updateItems()
    func updateSearchField(input searchString: String)
    func showAquaDetail(_ item: Aqua)
    func showAquaRequestVC()
}

protocol AquaListViewPresenterProtocol: AnyObject {
    func didSelect(at indexPath: IndexPath)
    func getRowType(by section: Int) -> AquaListViewRowType
    func getSelectedCellItem<T>(by indexPath: IndexPath) -> T
    func searchItems(input searchString: String)
}

class AquaListViewPresenter: AquaListViewPresenterProtocol {
    
    weak var delegate: AquaListViewDelegate?
    var lastSearchedString: String = ""
    var timer: Timer? // 타이핑이 끝난뒤 검색수행까지의 딜레이 타이머
    var hasResults: Bool = false
    var isFetching: Bool = false
    var isSearching: Bool = false
    var filteredItems = [Aqua]()
    var terms = [SearchTerm]() {
        didSet {
            delegate?.updateItems()
        }
    }
    
    init(delegate: AquaListViewDelegate? = nil) {
        self.delegate = delegate
        fetchSearchTerms()
    }
    
    func didSelect(at indexPath: IndexPath) {
        switch getRowType(by: indexPath.section) {
        case .aqua:
            let item = getSelectedCellItem(by: indexPath) as Aqua
            delegate?.showAquaDetail(item)
            break
        case .searchterm:
            delegate?.updateSearchField(input: terms[indexPath.row].keyword)
            break
        case .noResult:
//            delegate?.showAquaRequestVC()
            break
        default: break
        }
    }
    
    func getRowType(by section: Int) -> AquaListViewRowType {
        guard let type = AquaListViewRowType(rawValue: section) else { fatalError("Unknown row.") }
        return type
    }
    
    func getSelectedCellItem<T>(by indexPath: IndexPath) -> T {
        switch getRowType(by: indexPath.section) {
        case .searchterm: return terms[indexPath.row] as! T
        case .aqua: return filteredItems[indexPath.row] as! T
        case .loading: return 0 as! T
        case .noResult: return 0 as! T
        }
    }
    
    func deleteSearchTerm(_ row: Int) {
        terms.remove(at: row)
        UserDefaults.standard.set(try! PropertyListEncoder().encode(terms), forKey: "searchTerms")
    }
    
    func fetchSearchTerms() {
        do {
            if let data = UserDefaults.standard.value(forKey:"searchTerms") as? Data {
                terms = try PropertyListDecoder().decode([SearchTerm].self, from: data)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func textDidChange(input string: String) {
        isSearching = !string.isEmpty
        
        if !isSearching {
            isFetching = false
            hasResults = false
            delegate?.updateItems()
        }
    }
    
    func searchItems(input searchString: String) {
        let strippedString = searchString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        lastSearchedString = strippedString
        
        isSearching = !strippedString.isEmpty
        if !isSearching && strippedString.isEmpty { return }
        
        if !isFetching {
            isFetching = true
            hasResults = false
            filteredItems.removeAll()
            delegate?.updateItems()
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { [weak self] timer in
            guard let self = self else { return }
            
            self.isFetching = false
            let compoundPredicate = self.setPredicate(strippedString)
            self.filteredItems = CoreDataService.shared.fetch(object: Aqua.self, predicate: compoundPredicate)
            if self.isSearching {
                self.hasResults = !self.filteredItems.isEmpty
                if self.hasResults {
                    if !self.terms.contains(where: { $0.keyword == strippedString }) {
                        self.terms.insert(SearchTerm(date: Date(), keyword: strippedString), at: 0)
                        UserDefaults.standard.set(try! PropertyListEncoder().encode(self.terms), forKey: "searchTerms")
                    }
                }
            }
            self.delegate?.updateItems()
        }
    }
    
    func setPredicate(_ strippedString: String) -> NSCompoundPredicate {
        let searchItems = strippedString.components(separatedBy: " ") as [String]
        var andMatchPredicates = [NSPredicate]()
        
        for string in searchItems {
            do {
                let en = try NSRegularExpression(pattern: "[a-zA-Z]", options: .caseInsensitive)
                let kr = try NSRegularExpression(pattern: "[가-힣ㄱ-ㅎㅏ-ㅣ]", options: .caseInsensitive)
                let num = try NSRegularExpression(pattern: "[0-9]", options: .caseInsensitive)
                
                var field: String = "kname"
                if let _ = en.firstMatch(in: string, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, string.count)){
                    field = Aqua.CodingKeys.ename.stringValue
                    andMatchPredicates.append(NSPredicate(format: "\(field) CONTAINS[cd] %@", string))
                }
                else if let _ = kr.firstMatch(in: string, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, string.count)){
                    field = Aqua.CodingKeys.kname.stringValue
                    andMatchPredicates.append(NSPredicate(format: "\(field) CONTAINS[cd] %@", string))
                }
                else if let _ = num.firstMatch(in: string, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, string.count)){
                    field = Aqua.CodingKeys.age.stringValue
                    andMatchPredicates.append(NSPredicate(format: "\(field) == %@", string))
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
    }
    
    deinit {
        print("deinit AquaListViewPresenter")
    }
}

