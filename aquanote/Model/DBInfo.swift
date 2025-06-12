//
//  DBInfo.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/21.
//

import Foundation

enum Collection: String {
    case aquas = "aquas"
    case tags = "tasting-tags"
    case notes = "notes"
    
    func getType() -> AnyClass {
        switch self {
        case .aquas:
            return Aqua.self
        case .tags:
            return TastingTag.self
        case .notes:
            return Note.self
        }
    }
}

struct DBInfo: Codable, Equatable {
    let name: String
    let ver: Float
    
    init(name: String, ver: Float) {
        self.name = name
        self.ver = ver
    }
}
