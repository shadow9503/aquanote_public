//
//  Aqua+CoreDataProperties.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/21.
//
//

import Foundation
import CoreData


extension Aqua {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Aqua> {
        return NSFetchRequest<Aqua>(entityName: "Aqua")
    }

    @NSManaged public var kname: String?
    @NSManaged public var ename: String?
    @NSManaged public var age: String?
    @NSManaged public var price: String?
    @NSManaged public var category: String?
    @NSManaged public var strength: String?
    @NSManaged public var summary: String?
    @NSManaged public var nose: [String]?
    @NSManaged public var palate: [String]?
    @NSManaged public var finish: [String]?
    @NSManaged public var nation: String?
    @NSManaged public var image: String?
    @NSManaged public var addedOn: Date?

    enum CodingKeys: CodingKey {
        case kname
        case ename
        case category
        case summary
        case nation
        case age
        case strength
        case price
        case nose
        case palate
        case finish
        case image
        case addedOn
    }
}

extension Aqua : Identifiable {

}
