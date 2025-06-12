//
//  RootViewPresenter.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/03.
//
import Foundation
import Alamofire

@objc protocol ViewableProtocol {
    func setupView()
    @objc optional func configureView()
    func setupConstraints()
}

protocol RootViewDelegate: AnyObject {
    func needNetworkConnection()
    func didFailedUpdateApp(_ message: String)
    func didSuccessfulUpdateApp(_ message: String?)
    func didFailedNotedataSync(_ message: String)
    func didSuccessfulNotedataSync(_ message: String?)
    func didUpdateCheck(_ statue: VersionStatus)
}

protocol RootViewPresenterProtocol: AnyObject {
    //
}

enum VersionStatus {
    case old
    case lastest
}

enum VersionError: Error {
  case invalidResponse, invalidBundleInfo
}


class RootViewPresenter: RootViewPresenterProtocol {
    weak var delegate: RootViewDelegate?
    var newStatus: [DBInfo]?
    let APPLEID = "1672899188"
    var isUpdating: Bool = false
    var needUpdateCheck: Bool = true
    
    init(delegate: RootViewDelegate? = nil) {
        self.delegate = delegate
    }
    
    func appUpdateCheck() async {
        guard let delegate = delegate else { return }
        
        do {
            switch try await checkAppVersion() {
                case .old:
                    needUpdateCheck = true
                    delegate.didUpdateCheck(.old)
                    break
                case .lastest:
                    needUpdateCheck = false
                    delegate.didUpdateCheck(.lastest)
                    break
            }
            return
        } catch {
            print(error.localizedDescription)
            delegate.didFailedUpdateApp("앱 버전 체크에 실패했어요\n네트워크를 확인해주세요.")
            return
        }
    }
    
//    func dbUpdateCheck() async {
//        guard let delegate = delegate else { return }
//        
//        do {
//            switch try await checkDBVersion() {
//                case .old:
//                    CoreDataService.shared.deleteAllRecord(.aquas)
//                    CoreDataService.shared.deleteAllRecord(.tags)
//                    try await fetchData(.aquas)
//                    try await fetchData(.tags)
//                    UserDefaults.standard.set(try PropertyListEncoder().encode(self.newStatus), forKey: "DBInfo")
//                    break
//                case .lastest:
//                    // lastest
//                    break
//            }
//            delegate.didSuccessfulUpdateApp(nil)
//        } catch {
//            print(error.localizedDescription)
//            delegate.didFailedUpdateApp("DB 업데이트에 실패했어요\n네트워크를 확인해주세요.")
//        }
//    }
    
    func fetchData(_ model: Collection) async throws {
        do {
            switch model {
                
            case .aquas:
                try await AquaService().getAquas()
                break
            case .tags:
                try await TagService.shared.getTags()
                break
            default:
                break
            }
        } catch {
            throw error
        }
    }
    
    func checkAppVersion() async throws -> VersionStatus {
        // check bundleInfo
        guard let appInfo = Bundle.main.infoDictionary,
              let identifier = appInfo["CFBundleIdentifier"] as? String,
              let currentVersion = appInfo["CFBundleShortVersionString"] as? String
                else { throw VersionError.invalidBundleInfo }
        
        // update lastRunVersion (처음설치)
//        guard let lastRunVersion = UserDefaults.standard
//            .object(forKey: "VersionOfLastRun") as? String
//                else {
//                    UserDefaults.standard.set(currentVersion, forKey: "VersionOfLastRun")
//                    return .lastest
//                }
        
        let minimumVersion = try? await getMinimumAppVersion()
        
        let currentMajor = Int(currentVersion.components(separatedBy: ".")[0]) ?? 1
        let minimumMajor = Int(minimumVersion?.components(separatedBy: ".")[0] ?? "1") ?? 1
        
        let currentMinor = Int(currentVersion.components(separatedBy: ".")[1]) ?? 0
        let minimumMinor = Int(minimumVersion?.components(separatedBy: ".")[1] ?? "0") ?? 0
        
        let currentPatch = Int(currentVersion.components(separatedBy: ".")[2]) ?? 0
        let minimumPatch = Int(minimumVersion?.components(separatedBy: ".")[2] ?? "0") ?? 0
        
        if currentMajor < minimumMajor {
            return .old
        }
        
        if currentMinor < minimumMinor {
            return .old
        }
        
        if currentPatch < minimumPatch {
            return .old
        }
        
        return .lastest
        
        // 출시 이후 1.1이상 부터 appstore check
//        if NSString.init(string: "1.1").floatValue >
//            NSString.init(string: currentVersion).floatValue { return .lastest }
        
        // search new version
//        let itunesUrl = "http://itundes.apple.com/kr/lookup?bundleId=\(identifier)"
//        guard let url = URL(string: itunesUrl)
//            else { throw VersionError.invalidResponse }
//        
//        let request = AF.request(url)
//        let result = await request.serializingData().result
//
//        switch result {
//            case .success(let value):
//                let json = try JSONSerialization.jsonObject(
//                    with: value, options: [.allowFragments]
//                ) as? [String: Any]
//            
//                guard let result = (json?["results"] as? [Any])?.first as? [String: Any],
//                      let version = result["version"] as? String
//                        else { throw VersionError.invalidResponse } // 앱스토어 버전 가져오기
//
//                let appStoreVer = NSString.init(string: version).floatValue
//                let currentVer = NSString.init(string: currentVersion).floatValue
//                return appStoreVer > currentVer ? .old : .lastest
//
//            case .failure(let error):
//                print(error.localizedDescription)
//                throw VersionError.invalidResponse
//        }
    }
    
    func appVersionUpdate() {
       // id뒤에 값은 앱정보에 Apple ID에 써있는 숫자
       if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(APPLEID)"), UIApplication.shared.canOpenURL(url) {
          // 앱스토어로 이동
          if #available(iOS 10.0, *) {
             UIApplication.shared.open(url, options: [:], completionHandler: nil)
          } else {
              UIApplication.shared.openURL(url)
          }
       }
    }
    
    // 로컬 버전, 클라우드 버전을 확인하여 현재 업데이트가 필요한 DB의 리스트를 반환
//    func checkDBVersion() async throws -> [Collection] {
//        do {
//            if let data = UserDefaults.standard.data(forKey: "DBInfo") {
//                let currentVersion = try PropertyListDecoder().decode([DBInfo].self, from: data)
//                self.newVersion = try await AquaService.shared.getVersionInfo()
//
//                return self.newVersion!.filter { new in
//                    currentVersion.first { cur in
//                        print(new, cur)
//                        if new.name == cur.name && new.ver != cur.ver {
//                            return true
//                        } else {
//                            return false
//                        }
//                    } != nil
//                }.map { Collection(rawValue: $0.name)! }
//            } else {
//                print("최초 설치")
//                self.newVersion = try await AquaService.shared.getVersionInfo()
//                UserDefaults.standard.set(try? PropertyListEncoder().encode(self.newVersion), forKey: "DBInfo")
//                return [.aquas, .tags]
//            }
//        } catch {
//            print(error.localizedDescription)
//            throw error
//        }
//    }
    
    func checkDBVersion() async throws -> VersionStatus {
        do {
            // get new db status
            newStatus = try await AquaService().getVersionInfo()
            
            // check first run
            guard let data = UserDefaults.standard.data(forKey: "DBInfo"),
                  let currentStatus = try? PropertyListDecoder().decode([DBInfo].self, from: data) else {
                return .old
            }
            return currentStatus == newStatus ? .lastest : .old
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func getMinimumAppVersion() async throws -> String {
        do {
            return try await NoteService().getMinimumAppVersion()
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    deinit {
        print("deinit RootViewPresenter")
    }
}
