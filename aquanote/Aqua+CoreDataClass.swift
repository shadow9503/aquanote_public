//
//  Aqua+CoreDataClass.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/21.
//
//

import Foundation
import CoreData

@objc(Aqua)
public class Aqua: NSManagedObject, Codable {
    
    public required convenience init(from decoder: Decoder) throws {
        guard let managedObjectContext = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext,
                let entity = NSEntityDescription.entity(forEntityName: "Aqua", in: managedObjectContext)
                else { fatalError("Failed to decode Aqua") }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.kname = try container.decodeIfPresent(String.self, forKey: .kname)
        self.ename = try container.decodeIfPresent(String.self, forKey: .ename)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.summary = try container.decodeIfPresent(String.self, forKey: .summary)
        self.nation = try container.decodeIfPresent(String.self, forKey: .nation)
        self.age = try container.decodeIfPresent(String.self, forKey: .age)
        self.strength = try container.decodeIfPresent(String.self, forKey: .strength)
        self.price = try container.decodeIfPresent(String.self, forKey: .price)
        self.nose = try container.decodeIfPresent([String].self, forKey: .nose)
        self.palate = try container.decodeIfPresent([String].self, forKey: .palate)
        self.finish = try container.decodeIfPresent([String].self, forKey: .finish)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.addedOn = try container.decodeIfPresent(Date.self, forKey: .addedOn)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kname, forKey: .kname)
        try container.encode(ename, forKey: .ename)
        try container.encode(category, forKey: .category)
        try container.encode(summary, forKey: .summary)
        try container.encode(nation, forKey: .nation)
        try container.encode(age, forKey: .age)
        try container.encode(strength, forKey: .strength)
        try container.encode(price, forKey: .price)
        try container.encode(nose, forKey: .nose)
        try container.encode(palate, forKey: .palate)
        try container.encode(finish, forKey: .finish)
        try container.encode(image, forKey: .image)
        try container.encode(addedOn, forKey: .addedOn)
    }
}


public extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
