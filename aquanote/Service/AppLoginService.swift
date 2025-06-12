//
//  AppLoginService.swift
//  aquanote
//
//  Created by 유영훈 on 2023/02/24.
//

import Foundation
import AuthenticationServices
import Alamofire

@objc protocol AppleLoginServiceDelegate: AnyObject {
    @objc optional func didFailedRevokeAccount()
    @objc optional func diduccessRevokeAccount()
    @objc optional func didSuccessSignInAccount()
    @objc optional func didFailedSignInAccount()
    @objc optional func didSuccessSignOutAccount()
    @objc optional func didEndAuthorization()
}

enum LoginSessionStatus {
    case valid
    case invalid
}

final class AppleLoginService: NSObject {
    weak var viewController: UIViewController?
    weak var delegate: AppleLoginServiceDelegate?
    
    func setAppleLoginPresentationAnchorView(_ view: UIViewController) {
        self.viewController = view
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "userIdentityToken")
        UserDefaults.standard.removeObject(forKey: "useremail")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "userid")
        delegate?.didSuccessSignOutAccount?()
    }
    
    func checkLoginSession(_ completion: @escaping(LoginSessionStatus) -> Void) {
        guard let userIdentifier = UserDefaults.standard.string(forKey: "userid") else {
            completion(.invalid)
            return
        }
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                //인증성공 상태
                completion(.valid)
                break
            case .revoked:
                //인증만료 상태
                completion(.invalid)
                break
            default:
                //.notFound 등 이외 상태
                completion(.invalid)
                break
            }
        }
    }
}

extension AppleLoginService: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return viewController!.view.window!
    }
}

extension AppleLoginService: ASAuthorizationControllerDelegate {
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            print("TEST \(appleIDCredential.user)")
            print("TEST \(appleIDCredential.email)")
            print("TEST \(appleIDCredential.fullName)")
            print("TEST \(appleIDCredential.description)")
            
            let userIdentifier = appleIDCredential.user
            let userName = appleIDCredential.fullName?.nickname
            let userEmail = appleIDCredential.email
            UserDefaults.standard.set(userIdentifier, forKey: "userid")
            UserDefaults.standard.set(userName ?? "", forKey: "username")
            UserDefaults.standard.set(userEmail ?? "", forKey: "useremail")
            UserDefaults.standard.set(appleIDCredential.identityToken, forKey: "userIdentityToken")
            delegate?.didSuccessSignInAccount?()
            
            // 로그인 시에 refreshToken을 체크하고 없으면 받아서 저장.
            guard let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") else {
                if let authorizationCode = appleIDCredential.authorizationCode,
                    let code = String(data: authorizationCode, encoding: .utf8) {
                    Task {
                        await appleAuthorizationTokenVerify(code: code)
                    }
                }
                return
            }
        } else {
            print("credential is nil")
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        switch error {
        case ASAuthorizationError.failed,
            ASAuthorizationError.invalidResponse,
            ASAuthorizationError.unknown:
            print(error)
            delegate?.didFailedSignInAccount?()
            break
        default:
            delegate?.didEndAuthorization?()
            break
        }
    }
    
    func appleAuthorizationTokenVerify(code: String) async -> Result<(), Error> {
        do {
            let query = [URLQueryItem(name: "code", value: code)]
            let data = try await AquanoteAPI.get(.oauth, "/token", query)
            let refreshToken = String(data: data, encoding: .utf8)!
            UserDefaults.standard.set(refreshToken.trimmingCharacters(in: ["\""]), forKey: "refreshToken")
            return .success(())
        } catch {
            print(error.localizedDescription)
            return .failure(error)
        }
    }
    
    func appleAuthorizationTokenRevoke(refreshToken: String) async {
        do {
            let data = try await AquanoteAPI.get(.oauth, "/revoke",
                                                 [URLQueryItem(name: "code", value: refreshToken)])
            let notes = CoreDataService.shared.fetch(object: Note.self)
            if !notes.isEmpty {
                let uuids = notes.map { return $0.uuid! }
                CoreDataService.shared.deleteAllRecord(.notes)
                try? await FIRStoreService.shared.delete(.notes, uuids: uuids)
                
                let imagesArray = notes.map { return $0.images }
                for j in 0..<imagesArray.count {
                    Task {
                        if let images = imagesArray[j] {
                            for i in 0..<images.count {
                                let filename = images[i].components(separatedBy: "%2F").last
                                try? await FIRStorageService.shared.delete("/notes/\(filename!)")
                            }
                        }
                    }
                }
            }
            
            UserDefaults.standard.removeObject(forKey: "refreshToken")
            UserDefaults.standard.removeObject(forKey: "userIdentityToken")
            UserDefaults.standard.removeObject(forKey: "useremail")
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "userid")
            delegate?.diduccessRevokeAccount?()
        } catch {
            print(error.localizedDescription)
            delegate?.didFailedRevokeAccount?()
        }
    }
}
