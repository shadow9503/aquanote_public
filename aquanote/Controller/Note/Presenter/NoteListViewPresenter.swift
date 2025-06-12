//
//  NoteListViewPresenter.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/05.
//

import UIKit
import CoreData

protocol NoteListViewDelegate: AnyObject, ViewableProtocol {
    func didNothingFetched()
    func didSuccessFetch()
    func didFailedFetch()
    func didSuccessNoteDelete()
    func didFailedNoteDelete()
    func willNoteDelete()
    func beginListLoading()
    func endListLoading()
    func needsBackupList()
    func startPageLoading(style: UIBlurEffect.Style, text: String, opacity: CGFloat)
    func endPageLoading()
    func didFinishedSyncronizeProcess(_ message: String)
    func didFinishedBackupProcess(_ message: String)
}

protocol NoteListViewPresenterProtocol: AnyObject {
    func fetchList(_ row: Int)
    func createdNote()
    func refreshList()
    func deleteList(_ paths: [IndexPath], backup: Bool) -> Bool
}

class NoteListViewPresenter: NoteListViewPresenterProtocol {
    
    weak var delegate: NoteListViewDelegate?
    
    var isPaging: Bool = false
    var lastItemId: String = ""
    var isEndOfData: Bool = false
    var willRefresh: Bool = false
    
    var startOffset: Int = 0 // 쿼리시 요청할 아이템 인덱스 시작점
    var limit: Int = 20 // 쿼리시 요청할 아이템 개수
    var page: Int = 1 // 기존 페이지
    let perPage: Int = 20 // 페이지별 아이템 개수
    
    var totalItems = [Note]() {
        didSet {
            startOffset = totalItems.count
            page = (startOffset / perPage) + 1
            limit = (perPage - startOffset) == 0 ? perPage : ((page * perPage) - startOffset)
            if totalItems.isEmpty {
                numberOfRows = 0
            } else {
                lastItemId = totalItems.last!.uuid!.uuidString
                numberOfRows = totalItems.count
                delegate?.didSuccessFetch()
            }
        }
    }
    
    var items = [Note]() {
        didSet {
            if !items.isEmpty {
                totalItems.append(contentsOf: items)
            } else {
                if !totalItems.isEmpty {
                    isEndOfData = true
                    delegate?.didNothingFetched()
                } else {
                    delegate?.didSuccessFetch()
                }
            }
        }
    }
    
    var numberOfRows: Int = 0 // totalItems count
    
    init(delegate: NoteListViewDelegate? = nil) {
        self.delegate = delegate
    }
    
    func initDataSource() {
        delegate?.beginListLoading()
        items = fetch(at: startOffset, count: limit)
    }
    
    func refreshList() {
        totalItems = fetch(at: 0, count: perPage)
        isEndOfData = totalItems.isEmpty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.willRefresh = false
            self.delegate?.endPageLoading()
        }
    }
    
    func fetchList(_ row: Int) {
        
        // 다음 페이지를 불러올 시점 && 데이터의 끝이 아닐때
        let hasNextPage = (startOffset / perPage > 0) && !isEndOfData
        // 현재 보여진 item이 마지막 셀의 item인지 && 페이징 상태가 아닐때
        let canBePagination = (lastItemId == totalItems[row].uuid!.uuidString) && !isPaging
        
        if hasNextPage && canBePagination{
            delegate?.beginListLoading()
            items = fetch(at: startOffset, count: limit)
        }
    }
    
    func createdNote() {
        totalItems.insert(contentsOf: fetch(at: 0, count: 1), at: 0)
    }
    
    func fetch(at offset: Int = 0, count limit: Int = 0) -> [Note] {
        return CoreDataService.shared.fetch(object: Note.self, offset: offset, limit: limit)
    }
    
    func getNotBackupedItemsCount() -> Int {
        let predicate = NSPredicate(format: "isBackup == %@", NSNumber(value: 0))
        let nsCompundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
        return CoreDataService.shared.fetch(object: Note.self, predicate: nsCompundPredicate).count
    }
    
    func getItemsCount() -> Int {
//        let predicate = NSPredicate(format: "isBackup == %@", NSNumber(value: 0))w
        let nsCompundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [])
        return CoreDataService.shared.fetch(object: Note.self, predicate: nsCompundPredicate).count
    }
    
    func syncronizeList() {
        Task {
            let result = await FIRStoreService.shared.syncronize()
            switch result {
            case .success(let insertedCount):
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.delegate?.didFinishedSyncronizeProcess("\(insertedCount)개의 노트를 복원했어요")
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.delegate?.didFinishedSyncronizeProcess("복원에 실패했어요")
            }
        }
    }
    
    func backupList() {
        Task {
            switch await FIRStoreService.shared.backup(merge: false) {
            case .success(let updatedCount):
                switch await FIRStoreService.shared.syncronize() {
                case .success(let insertedCount):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.delegate?.didFinishedBackupProcess("\(updatedCount)개의 노트를 백업했어요")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    self.delegate?.didFinishedBackupProcess("백업에 실패했어요")
                }
                
//                if merge {
//                    switch await FIRStoreService.shared.syncronize() {
//                    case .success(let insertedCount):
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                            self.delegate?.didFinishedSyncronizeProcess("\(updatedCount)개의 노트를 백업하고\n\(insertedCount)개의 노트를 복원했어요")
//                        }
//                    case .failure(let error):
//                        print(error.localizedDescription)
//                        self.delegate?.didFinishedSyncronizeProcess("복원에 실패했어요")
//                    }
//                } else {
//                    let message = updatedCount != 0 ? "\(updatedCount)개의 노트를 백업했어요" : "백업할 노트가 없어요"
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                        self.delegate?.didFinishedBackupProcess(message)
//                    }
//                }
            case .failure(let error):
                print(error.localizedDescription)
                delegate?.didFinishedBackupProcess("백업에 실패했어요")
            }
        }
    }
     
    func deleteList(_ paths: [IndexPath], backup: Bool = false) -> Bool {
        delegate?.willNoteDelete()
        let targetIds = paths.map { return totalItems[$0.row].uuid! }
        let isDeleted = CoreDataService.shared.delete(object: Note.self, targets: targetIds)
        if isDeleted {
            
            // 이미지 삭제
            let imagesArray = paths.map { return totalItems[$0.row].images }
            for j in 0..<imagesArray.count {
                Task {
                    if let images = imagesArray[j] {
                        for i in 0..<images.count {
                            let filename = images[i].components(separatedBy: "%2F").last
                            try await FIRStorageService.shared.delete("/notes/\(filename!)")
                        }
                    }
                }
            }
            
            // 백업본 반영
            if backup {
                Task {
                    try? await FIRStoreService.shared.delete(.notes, uuids: targetIds)
                }
            }
            
            // local 반영
            targetIds.forEach {
                let id = $0
                totalItems = totalItems.filter {
                    $0.uuid != id
                }
                delegate?.didSuccessNoteDelete()
            }
        } else {
            delegate?.didFailedFetch()
        }
        return isDeleted
    }
    
    func ifNeedBackupList() {
        
    }
}

