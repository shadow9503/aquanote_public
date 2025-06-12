//
//  NoteService.swift
//  aquanote
//
//  Created by 유영훈 on 5/28/25.
//

import Alamofire

class NoteService {
    func getMinimumAppVersion() async throws -> String {
        do {
            let data = try await FIRStoreService.shared.get(.version)
            return data.first?["version"] as? String ?? "1.0.0"
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    deinit {
        print("deinit NoteService")
    }
}
