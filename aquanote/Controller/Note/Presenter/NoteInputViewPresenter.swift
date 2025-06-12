//
//  NoteInputViewPresenter.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/05.
//

import UIKit
import Alamofire

protocol NoteInputViewDelegate: AnyObject, ViewableProtocol {
    func didSuccessFetch()
    func didFailedFetch()
    func didSuccessUpload()
    func didFailedUplaod()
    func updateItems()
    func saveNote(_ willUploadImageUrls: [String])
    func didAddedImage(_ ifFullOfImage: Bool)
    func didRemovedImages()
    func didFinishedUpdate()
    func didFinishedCreate()
    func toastMessage(_ message: String)
}

protocol NoteInputViewPresenterProtocol: AnyObject {
    func fetchData()
}

class NoteInputViewPresenter: NoteInputViewPresenterProtocol {
    
    weak var delegate: NoteInputViewDelegate?
    let imageUrlPrefix: String = "https://storage.googleapis.com/aquanote-bdebe.appspot.com/notes%2F"
    var uploadedUrls = [String]()
    var willUploadImageUrls = [String]()
    var willUploadImages = [UIImage]() {
        didSet {
            needImageUpdate = true
        }
    }
    var imageSources = [UIImage]() {
        didSet {
            self.delegate?.updateItems()
        }
    }
    
    var defaultImage: UIImage = {
        let image = UIImage(named: "Bottle")?.withTintColor(.CustomColor.subTextColor, renderingMode: .alwaysOriginal)
        return image!
    }()
    
    var needImageUpdate: Bool = false
    let IMAGE_SELECTION_LIMIT: Int = 1
    
    init(delegate: NoteInputViewDelegate? = nil) {
        self.delegate = delegate
    }

    func fetchData() {
        delegate?.didSuccessFetch()
    }
    
    /// 노트 입력 폼에 추가
    func addImage<T>(_ image: T) {
        if !(imageSources.filter { $0 == defaultImage }.isEmpty) {
            imageSources = []
        }
        
        switch T.self {
        case is UIImage.Type:
            let image = image as! UIImage
            imageSources.append(image)
            if image == defaultImage { return }
            willUploadImages = imageSources
            delegate?.didAddedImage(imageSources.count == IMAGE_SELECTION_LIMIT)
            break
        case is String.Type:
            let urlString = image as! String
            Task(priority: .userInitiated) {
                    guard let url = URL(string: urlString),
                          let image = UIImage(data: try Data(contentsOf: url))
                            else { return }
                    DispatchQueue.main.async {
                        self.imageSources.append(image)
                        if self.uploadedUrls.isEmpty { // aqua detail 에서 이미지를 가져올때 url로 가져옴. ( uploaded url이 아님 )
                            self.willUploadImages = self.imageSources
                        }
                        self.delegate?.didAddedImage(self.imageSources.count == self.IMAGE_SELECTION_LIMIT)
                    }
            }
            break
        default:
            break
        }
    }
    
    /// 노트 입력 폼으로부터 제거
    func deleteImage() {
        let _ = willUploadImageUrls.popLast()
        let _ = willUploadImages.popLast()
        let _ = imageSources.popLast()
        if imageSources.isEmpty {
            needImageUpdate = !uploadedUrls.isEmpty
            addImage(defaultImage)
            delegate?.didRemovedImages()
        }
    }
    
    func initImageCollectionView() {
        willUploadImages = []
        willUploadImageUrls = []
        imageSources = [defaultImage]
        needImageUpdate = false
        delegate?.didRemovedImages()
    }
    
    func createNote(note: NoteModel, backup: Bool = false) {
        if CoreDataService.shared.create(object: Note.self, data: note) {
            if backup {
                Task {
                    try await FIRStoreService.shared.create(.notes, document: note)
                }
            }
            delegate?.didFinishedCreate()
        } else {
            // failed create
            delegate?.toastMessage("노트 저장에 실패했어요")
        }
    }
    
    func updateNote(note: NoteModel, backup: Bool = false) {
        if CoreDataService.shared.update(object: Note.self, data: note) {
            if backup {
                Task {
                    try await FIRStoreService.shared.update(.notes, document: note)
                }
            }
            delegate?.didFinishedUpdate()
        } else {
            // failed update
            delegate?.toastMessage("노트 저장에 실패했어요")
        }
    }
    
    // 1개의 이미지만을 허용
    func uploadImages() {
        Task {
            do {
                // delete uploaded image
                if let deleteTarget = uploadedUrls.first {
                    guard let filename = deleteTarget.components(separatedBy: "%2F").last else { return }
                    try? await FIRStorageService.shared.delete("/notes/\(filename)")
                }
                
                // upload new image
                guard let data = willUploadImages.first?.jpegData(compressionQuality: 0.75) else {
                    delegate?.saveNote(willUploadImageUrls)
                    return
                }
                
                let uuid = UUID().uuidString
                let url = "\(imageUrlPrefix)\(uuid).jpeg"
                willUploadImageUrls.append(url)
                delegate?.saveNote(willUploadImageUrls)
                try await FIRStorageService.shared.upload("/notes/\(uuid).jpeg", data)
            } catch {
                print(error.localizedDescription)
                delegate?.didFailedUplaod()
            }
        }
    }
    
//    @available(*, deprecated, message: "using functions - 성능문제로 직접 통신 사용")
//    func uploadImages(overwriting: Bool = true) async {
//        // FIXME: uploadedUrls가 빈값. 이미지 삭제시 에러
//        let params = [
//            "deleteList": uploadedUrls.map { return $0.components(separatedBy: "%2F").last },
//            "overwriting": overwriting
//        ] as! Parameters
//
//        var images = [(UIImage, String)]()
//        willUploadImages.forEach { image in
//            let uuidString = UUID().uuidString
//            let url = "\(imageUrlPrefix)\(uuidString).jpeg"
//            images.append((image, uuidString))
//            willUploadImageUrls.append(url)
//        }
//
//        delegate?.saveNote(willUploadImageUrls)
//
//        guard let data = try? await AquanoteAPI.upload(router:.upload("/notes/images", .post, params, images)) else {
//            delegate?.didFailedUplaod()
//            return
//        }
//        do {
//            let decoder = JSONDecoder()
//            let decoded = try decoder.decode(Response<String>.self, from: data)
//            let urls = decoded.returnValue
//            self.uploadedUrls = urls
//            delegate?.didSuccessUpload()
//        } catch {
//            print(error.localizedDescription)
//            delegate?.didFailedUplaod()
//        }
//    }
}

extension String {
    func toDecimal() -> String {
        let unFormatted = self.components(separatedBy: [","]).joined()
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        guard let number = Double(unFormatted) else { return self }
        let formatted = formatter.string(from: NSNumber(value: number))
        return formatted ?? ""
    }
    
    func toNumber() -> String {
        let separated = self.components(separatedBy: [","]).joined()
        return separated
    }
    
    func toImage() -> UIImage? {
        guard let url = URL(string: self), let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
