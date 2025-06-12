//
//  AquaService.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/21.
//

import Alamofire

class AquaService {
//    static let shared = AquaService()
//    private init() {}
    
    /// parsing과 함께 coredate에 저장함. 에러시에만 throw
    func getAquas() async throws {
        do {
            let data = try await AquanoteAPI.get(.app, "/aquas", [])
            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey.managedObjectContext] = CoreDataService.shared.context
            _ = try decoder.decode(Response<Aqua>.self, from: data)
            CoreDataService.shared.saveContext()
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func getVersionInfo() async throws -> [DBInfo] {
        do {
            let data = try await AquanoteAPI.get(.app, "/dbinfo", [])
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Response<DBInfo>.self, from: data)
            return decoded.returnValue
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    deinit {
        print("deinit AquaService")
    }
}
