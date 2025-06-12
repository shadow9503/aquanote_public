//
//  CoreDataService.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/11.
//

import CoreData
import Foundation
import FirebaseCrashlytics
import FirebaseFirestore

enum CoredataError: Error {
    case NotingResults, FailedBatchUpdate
}

class CoreDataService {
    static var shared: CoreDataService = CoreDataService()

    private init() { }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "aquanote")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // 조건 쿼리
    func fetch<Entity>(object: Entity.Type, predicate: NSCompoundPredicate, offset: Int = 0, limit: Int = 0) -> [Entity] {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "\(object)")
            request.fetchLimit = limit
            request.fetchOffset = offset
            request.predicate = predicate
            let results = try context.fetch(request)
            return results as! [Entity]
        } catch {
            print(error.localizedDescription)
            Crashlytics.crashlytics().record(error: error)
            return []
        }
    }
    
    // 기본 최신순 쿼리 (조건 없음)
    func fetch<Entity>(object: Entity.Type, offset: Int = 0, limit: Int = 0) -> [Entity] {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "\(object)")
            request.fetchLimit = limit
            request.fetchOffset = offset
            request.sortDescriptors = [NSSortDescriptor(key: "addedOn", ascending: false)]
            let results = try context.fetch(request)
            return results as! [Entity]
        } catch {
            print(error.localizedDescription)
            Crashlytics.crashlytics().record(error: error)
            return []
        }
    }
    
    // 모델 업데이트
    func update<Entity, T>(object: Entity.Type, data: T) -> Bool {
        print("YHTEST \(object) \(data)")
        switch T.self {
        case is NoteModel.Type:
            do {
                let note = data as! NoteModel
                let predicate = NSPredicate(format: "uuid IN %@", [note.uuid!])
                let nsCompundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "\(object)")
                request.predicate = nsCompundPredicate
                
                let origin = try context.fetch(request).first as! Note
                origin.setValue(note.uid, forKey: "uid")
                origin.setValue(note.uuid, forKey: "uuid")
                origin.setValue(note.addedOn, forKey: "addedOn")
                origin.setValue(note.editedOn, forKey: "editedOn")
                origin.setValue(note.title, forKey: "title")
                origin.setValue(note.images, forKey: "images")
                origin.setValue(note.nation, forKey: "nation")
                origin.setValue(note.category, forKey: "category")
                origin.setValue(note.strength, forKey: "strength")
                origin.setValue(note.tastingDate, forKey: "tastingDate")
                origin.setValue(note.age, forKey: "age")
                origin.setValue(note.price, forKey: "price")
                origin.setValue(note.tags, forKey: "tags")
                origin.setValue(note.nose, forKey: "nose")
                origin.setValue(note.palate, forKey: "palate")
                origin.setValue(note.finish, forKey: "finish")
                origin.setValue(note.comment, forKey: "comment")
                origin.setValue(note.etc, forKey: "etc")
                origin.setValue(note.isBackup, forKey: "isBackup")
                
                saveContext()
                return true
            } catch {
                print(error.localizedDescription)
                Crashlytics.crashlytics().record(error: error)
                return false
            }
        default:
            return false
        }
    }
    
    // 모델 삭제
    func delete<Entity>(object: Entity.Type, targets: [UUID]) -> Bool {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "\(object)")
            request.predicate = NSPredicate(format: "uuid IN %@", targets)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            let batchDelete = try context.execute(deleteRequest)
                as? NSBatchDeleteResult
            
            guard let deleteResult = batchDelete?.result
                as? [NSManagedObjectID]
                else { return false }
            
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: deleteResult],
                into: [context]
            )
            
            return true
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return false
        }
    }
    
    // 모델 생성
    func create<Entity, T>(object: Entity.Type, data: T) -> Bool {
        switch T.self {
        case is NoteModel.Type:
            let note = data as! NoteModel
            guard let _ = note.toManagedObject(in: context) else { return false }
            saveContext()
            return true
        default:
            return false
        }
    }
    
    // coredata 변경사항 저장
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /// 초기화할 모델 선택기
    func deleteAllRecord(_ model: Collection) {
        switch model {
        case .aquas:
            deleteAll(Aqua.fetchRequest())
            break
        case .tags:
            deleteAll(TastingTag.fetchRequest())
            break
        case .notes:
            deleteAll(Note.fetchRequest())
            break
        }
    }
    
    /// 특정 모델 데이터 모두 제거
    private func deleteAll<Entity>(_ request: NSFetchRequest<Entity>) {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "\(Entity.self)")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            let batchDelete = try context.execute(deleteRequest)
                as? NSBatchDeleteResult
            
            guard let deleteResult = batchDelete?.result
                as? [NSManagedObjectID]
                else { return }
            
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: deleteResult],
                into: [context]
            )
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// for dummy testing
    func batchInsertion<T>(_ data: [T]) throws -> Int {
        
        var index = 0
        let total = data.count
        
        var batchRequest: NSBatchInsertRequest!
        
        switch T.self {
            case is NoteModel.Type :
                let data = (data as! [NoteModel])
            
                batchRequest = NSBatchInsertRequest(entity: Note.entity(),
                                                        managedObjectHandler: { managedObject in
                    guard index < total else { return true }
                    if let note = managedObject as? Note {
                        let data = data[index]
                        note.uid = data.uid
                        note.uuid = data.uuid
                        note.addedOn = data.addedOn
                        note.editedOn = data.editedOn
                        note.title = data.title
                        note.images = data.images
                        note.tastingDate = data.tastingDate
                        note.nation = data.nation
                        note.category = data.category
                        note.strength = data.strength
                        note.age = data.age
                        note.price = data.price
                        note.tags = data.tags
                        note.nose = data.nose
                        note.palate = data.palate
                        note.finish = data.finish
                        note.comment = data.comment
                        note.etc = data.etc
                        note.isBackup = data.isBackup
                        
                        index += 1
                        return false
                    }
                    
                    return true
                })
                break
            case is [String : Any].Type:
                let data = data as! [[String : Any]]
            
                batchRequest = NSBatchInsertRequest(entity: Note.entity(),
                                                        managedObjectHandler: { managedObject in
                    guard index < total else { return true }
                    if let note = managedObject as? Note {
                        let data = data[index]
                        note.uid = data["uid"] as? String
                        note.uuid = UUID(uuidString: data["uuid"] as! String)
                        note.addedOn = (data["addedOn"] as? Timestamp)?.dateValue()
                        note.editedOn = (data["editedOn"] as? Timestamp)?.dateValue()
                        note.title = data["title"] as? String
                        note.images = data["images"] as? [String]
                        note.tastingDate = (data["tastingDate"] as? Timestamp)?.dateValue()
                        note.nation = data["nation"] as? String
                        note.category = data["category"] as? String
                        note.strength = data["strength"] as? String
                        note.age = data["age"] as? String
                        note.price = data["price"] as? String
                        note.tags = data["tags"] as? [String]
                        note.nose = data["nose"] as? String
                        note.palate = data["palate"] as? String
                        note.finish = data["finish"] as? String
                        note.comment = data["comment"] as? String
                        note.etc = data["etc"] as? String
                        note.isBackup = data["isBackup"] as! Bool
                        
                        index += 1
                        return false
                    }
                    
                    return true
                })
                break
            default:
                return 0
        }
        
        do {
            batchRequest.resultType = .objectIDs
            
            let batchInsert = try context.execute(batchRequest)
                as? NSBatchInsertResult
            
            guard let batchResult = batchInsert?.result
                as? [NSManagedObjectID]
                else { return 0 }
            
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSInsertedObjectsKey: batchResult],
                into: [context]
            )
            
            return batchResult.count
        } catch {
            print(error.localizedDescription)
            throw error
        }
        
    }
        
    // 노트 복원 시에 일괄 생성을 위한 기능
    func batchInsertion(_ documents: [[String : Any]]) throws -> Int {
        
        var index = 0
        let total = documents.count
        
        let batchRequest = NSBatchInsertRequest(entity: Note.entity(),
                                                managedObjectHandler: { managedObject in
            guard index < total else { return true }
            if let note = managedObject as? Note {
                let data = documents[index]
                note.uid = data["uid"] as? String
                note.uuid = UUID(uuidString: data["uuid"] as! String)
                note.addedOn = (data["addedOn"] as? Timestamp)?.dateValue()
                note.editedOn = (data["editedOn"] as? Timestamp)?.dateValue()
                note.title = data["title"] as? String
                note.images = data["images"] as? [String]
                note.tastingDate = (data["tastingDate"] as? Timestamp)?.dateValue()
                note.nation = data["nation"] as? String
                note.category = data["category"] as? String
                note.strength = data["strength"] as? String
                note.age = data["age"] as? String
                note.price = data["price"] as? String
                note.tags = data["tags"] as? [String]
                note.nose = data["nose"] as? String
                note.palate = data["palate"] as? String
                note.finish = data["finish"] as? String
                note.comment = data["comment"] as? String
                note.etc = data["etc"] as? String
                note.isBackup = data["isBackup"] as! Bool
                
                index += 1
                return false
            }
            
            return true
        })
        
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            batchRequest.resultType = .objectIDs
            
            let batchInsert = try context.execute(batchRequest)
                as? NSBatchInsertResult
            
            guard let batchResult = batchInsert?.result
                as? [NSManagedObjectID]
                else { return 0 }
            
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSInsertedObjectsKey: batchResult],
                into: [context]
            )
            
            return batchResult.count
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    // 노트의 일부 속성을 일괄 업데이트 하기위한 기능
    func update(_ predicate: NSPredicate, propertiesToUpdate: [String : Any]) throws -> Int {
        // 백업되지 않은 리스트 모두를 백업 상태로 변경.
        let batchRequest = NSBatchUpdateRequest(entity: Note.entity())
        batchRequest.propertiesToUpdate = propertiesToUpdate
        batchRequest.resultType = .updatedObjectIDsResultType
        batchRequest.predicate = predicate
        
        do {
            let batchUpdate = try context.execute(batchRequest)
                as? NSBatchUpdateResult
            
            guard let batchResult = batchUpdate?.result
                as? [NSManagedObjectID]
                else { throw CoredataError.NotingResults }
            
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSUpdatedObjectsKey: batchResult],
                into: [context]
            )
            
            return batchResult.count
        } catch {
            print(error.localizedDescription)
            throw CoredataError.FailedBatchUpdate
        }
        
    }
}
