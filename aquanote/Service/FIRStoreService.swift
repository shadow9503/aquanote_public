//
//  FIRStoreService.swift
//  aquanote
//
//  Created by 유영훈 on 2023/02/25.
//

import FirebaseFirestore

class FIRStoreService {
    
    static let shared = FIRStoreService()
    let store = Firestore.firestore()
    var isWaitingPendingWrites: Bool = false
    
    private init() {
//        store.useEmulator(withHost: "127.0.0.1", port: 8088)
    }
    
    enum FirestoreCollection: String {
        case version = "/version"
        case notes = "/notes"
        case tags = "/tasting-tags"
    }
    
    func processPendingWrites() {
        isWaitingPendingWrites = true
        store.waitForPendingWrites { error in
            self.isWaitingPendingWrites = false
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }
    
    func create(_ collection: FirestoreCollection, document: Any) async throws {
        switch collection {
            case .notes:
                do {
                    let note = document as! NoteModel
                    guard let data = note.toDictionary else { return }
                    var mutableData = data
                    mutableData["addedOn"] = FieldValue.serverTimestamp()
                    mutableData["isBackup"] = true
                    if let tastingDate = note.tastingDate {
                        mutableData["tastingDate"] = Timestamp(date: tastingDate)
                    }
                    let willSetData = mutableData
                
                    let docRef = store.collection(collection.rawValue)
                
                    try await docRef.document("/\(note.uuid!.uuidString)")
                        .setData(willSetData, merge: true)
                    
                    var mutableNote = note
                    mutableNote.isBackup = true
                    let _ = CoreDataService.shared.update(object: Note.self, data: mutableNote)
                
                } catch {
                    throw error
                }
//                let task = Task {
//                    // 네트워크 문제시 자동 재시도 되며 재연결 시 업로드됨.
//                    // 도중 앱 종료시 중단됨.
//                    return try await docRef.document("/\(note.uuid!.uuidString)")
//                        .setData(willSetData, merge: true)
//                }
//
//                switch await task.result {
//                    case .success():
//                        // 백업 상태를 저장.
//                        var mutableNote = note
//                        mutableNote.isBackup = true
//                        let _ = CoreDataService.shared.update(object: Note.self, data: mutableNote)
//                        break
//                    case .failure(let error):
//                        throw error
//                }
                
                break
            case .tags, .version:
                break
        }
    }
    
    func delete(_ collection: FirestoreCollection, uuids: [UUID]) async throws {
        switch collection {
            case .notes:
                let docRef = store.collection(collection.rawValue)
                let task = Task {
                    let batch = store.batch()
                    uuids.forEach {
                        batch.deleteDocument(docRef.document("/\($0.uuidString)"))
                    }
                    try await batch.commit()
                }
            
                switch await task.result {
                    case .success():
                        break
                    case .failure(let error):
                        throw error
                }
                   
                break
            case .tags, .version:
                break
        }
    }
    
    func update(_ collection: FirestoreCollection, document: Any) async throws {
        switch collection {
            case .notes:
                let note = document as! NoteModel
                guard let data = note.toDictionary else { return }
                var mutableData = data
                mutableData["editedOn"] = FieldValue.serverTimestamp()
                mutableData["addedOn"] = Timestamp(date: note.addedOn)
                mutableData["isBackup"] = true
                if let tastingDate = note.tastingDate {
                    mutableData["tastingDate"] = Timestamp(date: tastingDate)
                }
                let willSetData = mutableData
            
                let docRef = store.collection(collection.rawValue)
                let task = Task {
                    try await docRef.document("/\(note.uuid!.uuidString)")
                        .setData(willSetData, merge: true)
                }
            
                switch await task.result {
                    case .success():
                        var mutableNote = note
                        mutableNote.isBackup = true
                        let _ = CoreDataService.shared.update(object: Note.self, data: mutableNote)
                        break
                    case .failure(let error):
                        throw error
                }
                   
                break
        case .tags, .version:
                break
        }
    }
    
    /// true: 아직 서버에서 가져오지못한 백업본이 존재함.
    func syncronizingCheck() async throws -> Bool {
        guard let uid = UserDefaults.standard.string(forKey: "userid") else {
            let error = NSError(domain: "apple login session is invalid", code: 0)
            throw error
        }
        
        let docRef = store.collection(FirestoreCollection.notes.rawValue)
        let query = try await docRef.whereField("uid", isEqualTo: uid).getDocuments()
        let uuids = query.documents.map { return UUID(uuidString: ($0.data()["uuid"] as! String)) }

        
        let predicate = NSPredicate(format: "uuid IN %@", uuids)
        let nsCompundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
        let resultsCount = CoreDataService.shared.fetch(object: Note.self, predicate: nsCompundPredicate).count
        return resultsCount == uuids.count
    }
    
    func get(_ collection: FirestoreCollection) async throws -> [[String : Any]] {
        switch collection {
        case .version:
            let docRef = store.collection(collection.rawValue)
            let version = try await docRef.document("minimum").getDocument().get("version") as? String ?? ""
            return [["version": version]]
        case .notes:
            guard let uid = UserDefaults.standard.string(forKey: "userid") else {
                let error = NSError(domain: "apple login session is invalid", code: 0)
                throw error
            }
            
            let docRef = store.collection(collection.rawValue)
            let query = try await docRef.whereField("uid", isEqualTo: uid).getDocuments()
            let dictionaryArray = query.documents.map { return $0.data() }
            return dictionaryArray
        case .tags:
            return []
        }
    }
    
    func syncronize() async -> Result<Int, Error> {
        
        CoreDataService.shared.deleteAllRecord(.notes)
        
        guard let uid = UserDefaults.standard.string(forKey: "userid") else {
            let error = NSError(domain: "apple login session is invalid", code: 0)
            return .failure(error)
        }

        do {
            let docRef = store.collection(FirestoreCollection.notes.rawValue)
            let dictionaryArray = try await docRef.whereField("uid", isEqualTo: uid)
                .getDocuments()
                .documents
                .map { return $0.data() }
            let insertedCount = try CoreDataService.shared.batchInsertion(dictionaryArray)
            return .success(insertedCount)
        } catch {
            return .failure(error)
        }
        
//        let task = Task {
//            let query = try await docRef.whereField("uid", isEqualTo: uid).getDocuments()
//            let dictionaryArray = query.documents.map { return $0.data() }
//            return try CoreDataService.shared.batchInsertion(dictionaryArray)
//        }
//
//        switch await task.result {
//            case .success(let value):
//                return .success(value)
//            case .failure(let error):
//                return .failure(error)
//        }
    }
    
    /// 대상 uuid와 작업성공 여부만 반환
    struct CoredataSimpleResults {
        let isSuccess: Bool
        let uuid: UUID
    }
    
    func deleteCloudNotes() async throws {
        do {
            guard let uid = UserDefaults.standard.string(forKey: "userid") else {
                let error = NSError(domain: "apple login session is invalid", code: 0)
                throw error
            }
            
            let batch = store.batch()
            
            let docRef = store.collection(FirestoreCollection.notes.rawValue)
            let query = try await docRef.whereField("uid", isEqualTo: uid).getDocuments()
            
            for doc in query.documents {
                batch.deleteDocument(doc.reference)
            }
            
            try await batch.commit()
        } catch {
            throw error
        }
    }
    
    /// merge: false시 기존 백업본을 모두 지우고 현재 노트들만 백업한다. / merge: true 백업 누락본만 따로 백업.
    func backup(merge: Bool) async -> Result<Int, Error> {
        do {
            var willBackupItems = CoreDataService.shared.fetch(object: Note.self)
            if merge {
                willBackupItems = willBackupItems.filter { $0.isBackup == false }
            } else {
                try await deleteCloudNotes()
            }

            guard let uid = UserDefaults.standard.string(forKey: "userid") else {
                let error = NSError(domain: "apple login session is invalid", code: 0)
                return .failure(error)
            }

            let batch = store.batch()
            for item in willBackupItems {
                item.uid = uid
                let data = item.toParameter
                var mutableData = data
                mutableData["addedOn"] = Timestamp(date: item.addedOn!)
                mutableData["isBackup"] = true
                if let tastingDate = item.tastingDate {
                    mutableData["tastingDate"] = Timestamp(date: tastingDate)
                }
                if let editedOn = item.editedOn {
                    mutableData["editedOn"] = Timestamp(date: editedOn)
                }
                let willSetData = mutableData
                let docRef = self.store.collection(FirestoreCollection.notes.rawValue)
                    .document("/\(item.uuid!.uuidString)")
                batch.setData(willSetData, forDocument: docRef, merge: true)
            }
            
            try await batch.commit()
    
            let uuids = willBackupItems.map { return $0.uuid }
            let predicate = NSPredicate(format: "uuid IN %@", uuids)
            let properties = ["isBackup" : NSNumber(value: 1)]
            let updatedCount = try CoreDataService.shared.update(predicate, propertiesToUpdate: properties)

            return .success(updatedCount)
        } catch {
            print(error.localizedDescription)
            return .failure(error)
        }
    }
}

