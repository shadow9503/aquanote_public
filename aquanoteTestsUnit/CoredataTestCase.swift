//
//  CoredataTestCase.swift
//  aquanoteTestsUnit
//
//  Created by 유영훈 on 2023/03/23.
//

import XCTest
import CoreData
@testable import aquanote

open class CoredataTestCase: XCTestCase {
    
    public private(set) var persistentContainer: NSPersistentContainer!

    public var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    open override func setUpWithError() throws {
        try super.setUpWithError()
        persistentContainer = try mockNSPersistentContainer()
        try initStub(3)
//        try test_coredata_fetch()
    }

    open override func tearDownWithError() throws {
        persistentContainer = nil
        try super.setUpWithError()
    }

    open func mockNSPersistentContainer() throws -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "aquanote")
        
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }
    
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
    
    func initStub(_ numberOfData: Int) throws {
        XCTAssertNoThrow(try test_coredata_create(numberOfData))
    }
    
    func test_coredata_create(_ numberOfData: Int) throws {
        for i in stride(from: 0, to: numberOfData, by: 1) {
            let note = NoteModel(uid: "uid", uuid: UUID(), addedOn: Date(), editedOn: Date(), title: "test_title_\(i)", images: [], tastingDate: nil, nation: "", category: "", strength: "50", age: "9", price: "73000", tags: [], nose: "nose~", palate: "palate~", finish: "finish~", comment: "comment~", etc: "etc~", isBackup: false)
            let result = note.toManagedObject(in: context)
            XCTAssertNotNil(result)
            saveContext()
        }
    }
    
    func test_coredata_fetch() throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let result = try context.fetch(request)
        XCTAssertGreaterThan(result.count, 0)
    }
    
    func test_coredate_update() throws {
        
    }
    
    func test_coredate_delete() throws {
        
    }
}
