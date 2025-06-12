//
//  TagService.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/22.
//

import Alamofire

class TagService {
    static let shared = TagService()
    private init() {}
    
    func getTags() async throws {
        do {
            let data = try await AquanoteAPI.get(.app, "/tags", [])
            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey.managedObjectContext] = CoreDataService.shared.context
            _ = try decoder.decode(Response<TastingTag>.self, from: data)
            CoreDataService.shared.saveContext()
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}
