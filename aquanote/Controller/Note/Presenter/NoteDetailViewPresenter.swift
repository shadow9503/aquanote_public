//
//  NoteDetailViewPresenter.swift
//  aquanote
//
//  Created by 유영훈 on 2023/01/26.
//

import Foundation
import CoreData

protocol NoteDetailViewDelegate: AnyObject, ViewableProtocol {
    func didSuccessFetch(item: Note)
    func didFailedFetch()
}

protocol NoteDetailViewPresenterProtocol: AnyObject {
    func deleteNote(backup: Bool) -> Bool
    func fetchNote(id: UUID)
}

class NoteDetailViewPresenter: NoteDetailViewPresenterProtocol {
    weak var delegate: NoteDetailViewDelegate?
    var item: Note?
    
    init(delegate: NoteDetailViewDelegate? = nil) {
        self.delegate = delegate
    }
    
    func fetchNote(id: UUID) {
        let predicate = NSPredicate(format: "uuid IN %@", [id])
        let nsCompundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
        guard let note = CoreDataService.shared.fetch(object: Note.self, predicate: nsCompundPredicate).first else {
            delegate?.didFailedFetch()
            return
        }
        item = note
        delegate?.didSuccessFetch(item: note)
    }
    
    func deleteNote(backup: Bool = false) -> Bool {
        guard let item = item else { return false }
        let isDeleted = CoreDataService.shared.delete(object: Note.self, targets: [item.uuid!])
        if isDeleted {
            Task {
                if let images = item.images {
                    for i in 0..<images.count {
                        let filename = images[i].components(separatedBy: "%2F").last
                        try await FIRStorageService.shared.delete("/notes/\(filename!)")
                    }
                }
            }
            if backup {
                Task {
                    try await FIRStoreService.shared.delete(.notes, uuids: [item.uuid!])
                }
            }
        }
        return isDeleted
    }
}
