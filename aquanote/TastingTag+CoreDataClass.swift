//
//  TastingTag+CoreDataClass.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/22.
//
//

import Foundation
import CoreData

@objc(TastingTag)
public class TastingTag: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let managedObjectContext = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext,
                let entity = NSEntityDescription.entity(forEntityName: "TastingTag", in: managedObjectContext)
                else { fatalError("Failed to decode TastingTag") }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.kname = try container.decodeIfPresent(String.self, forKey: .kname)
        self.ename = try container.decodeIfPresent(String.self, forKey: .ename)
        self.desc = try container.decodeIfPresent(String.self, forKey: .desc)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kname, forKey: .kname)
        try container.encode(ename, forKey: .ename)
        try container.encode(desc, forKey: .desc)
    }
}
