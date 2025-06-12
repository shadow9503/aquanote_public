//
//  TastingTag+CoreDataProperties.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/22.
//
//

import Foundation
import CoreData


extension TastingTag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TastingTag> {
        return NSFetchRequest<TastingTag>(entityName: "TastingTag")
    }

    @NSManaged public var kname: String?
    @NSManaged public var ename: String?
    @NSManaged public var desc: String?

    enum CodingKeys: String, CodingKey {
        case kname
        case ename
        case desc = "description"
    }
}

extension TastingTag : Identifiable {

}
