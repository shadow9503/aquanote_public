//
//  Version.swift
//  aquanote
//
//  Created by 유영훈 on 5/28/25.
//

import Foundation

struct VersionInfo: Codable, Equatable {
    let version: String
    
    init(version: String) {
        self.version = version
    }
}
