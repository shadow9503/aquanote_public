//
//  NoteModel.swift
//  aquanote
//
//  Created by 유영훈 on 2023/03/17.
//

import Foundation
import CoreData

struct NoteModel: Encodable {
    var uid: String
    var uuid: UUID?
    var addedOn: Date
    var editedOn: Date?
    var title: String
    var images: [String]?
    var tastingDate: Date?
    var nation: String?
    var category: String?
    var strength: String?
    var age: String?
    var price: String?
    var tags: [String]?
    var nose: String?
    var palate: String?
    var finish: String?
    var comment: String?
    var etc: String?
    var isBackup: Bool
}


extension NoteModel {
    func toManagedObject(in context: NSManagedObjectContext) -> NSManagedObject? {
        guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: context) else { return nil }
        let object = NSManagedObject(entity: entity, insertInto: context) as! Note
        object.uid = uid
        object.uuid = uuid
        object.addedOn = addedOn
        object.age = age
        object.category = category
        object.editedOn = editedOn
        object.etc = etc
        object.finish = finish
        object.images = images
        object.nation = nation
        object.nose = nose
        object.palate = palate
        object.price = price
        object.strength = strength
        object.tags = tags
        object.title = title
        object.tastingDate = tastingDate
        object.comment = comment
        object.isBackup = isBackup
        return object
    }
    
    var toDictionary: [String : Any]? {
        guard let object = try? JSONEncoder().encode(self) else { return nil }
        guard let dictionary = try? JSONSerialization.jsonObject(with: object, options: []) as? [String:Any] else { return nil }
        return dictionary
    }
}
