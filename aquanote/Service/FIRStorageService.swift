//
//  FirebaseStorage.swift
//  aquanote
//
//  Created by 유영훈 on 2023/02/18.
//

import FirebaseStorage

class FIRStorageService {
    
    static let shared = FIRStorageService()
    private let storageRef = Storage.storage().reference()
    
    private init() {
//        Storage.storage().useEmulator(withHost: "127.0.0.1", port: 8088)
    }
    
    func delete(_ path: String) async throws {
        do {
            let ref = storageRef.child(path)
            try await ref.delete()
        } catch {
            throw error
        }
    }
    
    func upload(_ path: String, _ data: Data) async throws -> StorageMetadata {
        do {
            let ref = storageRef.child(path)
            return try await ref.putDataAsync(data)
        } catch {
            throw error
        }
    }
}
