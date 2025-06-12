//
//  Note+CoreDataClass.swift
//  aquanote
//
//  Created by 유영훈 on 2023/02/17.
//
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let managedObjectContext = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext,
                let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedObjectContext)
                else { fatalError("Failed to decode Note") }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uid = try container.decodeIfPresent(String.self, forKey: .uid)
        self.uuid = try container.decodeIfPresent(UUID.self, forKey: .uuid)
        self.addedOn = try container.decodeIfPresent(Date.self, forKey: .addedOn)
        self.editedOn = try container.decodeIfPresent(Date.self, forKey: .editedOn)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.images = try container.decodeIfPresent([String].self, forKey: .images)
        self.tastingDate = try container.decodeIfPresent(Date.self, forKey: .tastingDate)
        self.nation = try container.decodeIfPresent(String.self, forKey: .nation)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.strength = try container.decodeIfPresent(String.self, forKey: .strength)
        self.age = try container.decodeIfPresent(String.self, forKey: .age)
        self.price = try container.decodeIfPresent(String.self, forKey: .price)
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
        self.nose = try container.decodeIfPresent(String.self, forKey: .nose)
        self.palate = try container.decodeIfPresent(String.self, forKey: .palate)
        self.finish = try container.decodeIfPresent(String.self, forKey: .finish)
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
        self.etc = try container.decodeIfPresent(String.self, forKey: .etc)
        self.isBackup = try container.decodeIfPresent(Bool.self, forKey: .isBackup)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(addedOn, forKey: .addedOn)
        try container.encode(editedOn, forKey: .editedOn)
        try container.encode(title, forKey: .title)
        try container.encode(images, forKey: .images)
        try container.encode(tastingDate, forKey: .tastingDate)
        try container.encode(nation, forKey: .nation)
        try container.encode(category, forKey: .category)
        try container.encode(strength, forKey: .strength)
        try container.encode(age, forKey: .age)
        try container.encode(price, forKey: .price)
        try container.encode(tags, forKey: .tags)
        try container.encode(nose, forKey: .nose)
        try container.encode(palate, forKey: .palate)
        try container.encode(finish, forKey: .finish)
        try container.encode(comment, forKey: .comment)
        try container.encode(etc, forKey: .etc)
        try container.encode(isBackup, forKey: .isBackup)
    }
}
