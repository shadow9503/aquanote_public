//
//  Note+CoreDataProperties.swift
//  aquanote
//
//  Created by 유영훈 on 2023/02/17.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var uid: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var addedOn: Date?
    @NSManaged public var editedOn: Date?
    @NSManaged public var tastingDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var age: String?
    @NSManaged public var category: String?
    @NSManaged public var price: String?
    @NSManaged public var nation: String?
    @NSManaged public var strength: String?
    @NSManaged public var images: [String]?
    @NSManaged public var finish: String?
    @NSManaged public var nose: String?
    @NSManaged public var palate: String?
    @NSManaged public var tags: [String]?
    @NSManaged public var etc: String?
    @NSManaged public var comment: String?
    @NSManaged public var isBackup: Bool

    enum CodingKeys: String, CodingKey {
        case uid
        case uuid
        case addedOn
        case editedOn
        case title
        case images
        case tastingDate
        case nation
        case category
        case strength
        case age
        case price
        case tags
        case nose
        case palate
        case finish
        case comment
        case etc
        case isBackup
    }
    
    var toNoteModel: NoteModel {
        return NoteModel(
            uid: self.uid!,
            uuid: self.uuid!,
            addedOn: self.addedOn!,
            editedOn: self.editedOn,
            title: self.title!,
            images: self.images,
            tastingDate: self.tastingDate,
            nation: self.nation,
            category: self.category,
            strength: self.strength,
            age: self.age,
            price: self.price,
            tags: self.tags,
            nose: self.nose,
            palate: self.palate,
            finish: self.finish,
            comment: self.comment,
            etc: self.etc,
            isBackup: self.isBackup
        )
    }
}

extension Note : Identifiable {

}

//struct NoteModel: Encodable {
//    var uid: String
//    var uuid: UUID?
//    var addedOn: Date
//    var editedOn: Date?
//    var title: String
//    var images: [String]?
//    var tastingDate: Date?
//    var nation: String?
//    var category: String?
//    var strength: String?
//    var age: String?
//    var price: String?
//    var tags: [String]?
//    var nose: String?
//    var palate: String?
//    var finish: String?
//    var comment: String?
//    var etc: String?
//    var isBackup: Bool
//}
//
//
//extension NoteModel {
//    func toManagedObject(in context: NSManagedObjectContext) -> NSManagedObject? {
//        guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: context) else { return nil }
//        let object = NSManagedObject(entity: entity, insertInto: context) as! Note
//        object.uid = uid
//        object.uuid = uuid
//        object.addedOn = addedOn
//        object.age = age
//        object.category = category
//        object.editedOn = editedOn
//        object.etc = etc
//        object.finish = finish
//        object.images = images
//        object.nation = nation
//        object.nose = nose
//        object.palate = palate
//        object.price = price
//        object.strength = strength
//        object.tags = tags
//        object.title = title
//        object.tastingDate = tastingDate
//        object.comment = comment
//        object.isBackup = isBackup
//        return object
//    }
//    
//    var toDictionary: [String : Any]? {
//        guard let object = try? JSONEncoder().encode(self) else { return nil }
//        guard let dictionary = try? JSONSerialization.jsonObject(with: object, options: []) as? [String:Any] else { return nil }
//        return dictionary
//    }
//}
