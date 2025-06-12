//
//  AlamoFire.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/05.
//

import Alamofire
import UIKit
import FirebaseCrashlytics

typealias AquanoteResponse<Value> = Dictionary<String, Value>

protocol DefaultRouter: URLRequestConvertible {
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var token: String { get }
    var parameters: Parameters { get }
    var query: [URLQueryItem] { get }
    var headers: HTTPHeaders { get }
    var multipart: MultipartFormData { get }
    func asURLRequest() throws -> URLRequest
}

enum FunctionsApp: String {
    case oauth = "/oauth"
    case app = "/app"
}

enum FirestoreRouter: DefaultRouter {
    case get(_ app: FunctionsApp, _ path: String, _ query: [URLQueryItem])
    case post(_ app: FunctionsApp, _ path: String, _ params: Parameters)
    case put(_ app: FunctionsApp, _ path: String, _ params: Parameters)
    case delete(_ app: FunctionsApp, _ path: String)
    case request(_ app: FunctionsApp, _ path: String, _ method: HTTPMethod, _ params: Parameters)
    case upload(_ app: FunctionsApp, _ path: String, _ method: HTTPMethod, _ params: Parameters?, _ images: [(UIImage, String)])
    
    var baseURL: String {
        return "http://127.0.0.1"
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .get(_,_,_):
            return .get
        case .post(_,_,_):
            return .post
        case .put(_,_,_):
            return .put
        case .delete(_,_):
            return .delete
        case .request(_,_,let method,_):
            return method
        case .upload(_,_,let method,_,_):
            return method
        }
    }
    
    var path: String {
        switch self {
        case .get(let app,let path,_):
            return "\(app.rawValue)\(path)"
        case .post(let app, let path,_):
            return "\(app)\(path)"
        case .put(let app, let path,_):
            return "\(app)\(path)"
        case .delete(let app, let path):
            return "\(app)\(path)"
        case .request(let app, let path,_,_):
            return "\(app)\(path)"
        case .upload(let app, let path,_,_,_):
            return "\(app)\(path)"
        }
    }
    
    var token: String {
        return ""
    }
    
    var query: [URLQueryItem] {
        switch self {
        case .get(_,_,let query):
            return query
        case .post(_, _, _):
            return []
        case .put(_, _, _):
            return []
        case .delete(_, _):
            return []
        case .request(_, _, _, _):
            return []
        case .upload(_, _, _, _, _):
            return []
        }
    }
    
    var parameters: Alamofire.Parameters {
        switch self {
        case .post(_,_,let params):
            return params
        case .put(_,_,let params):
            return params
        case .request(_,_,_,let params):
            return params
        case .upload(_,_,_,let params,_):
            return params ?? Parameters()
        default:
            return Parameters()
        }
    }
    
    var headers: Alamofire.HTTPHeaders {
        var headers = HTTPHeaders.default
//        headers.add(.authorization(bearerToken: token))
        switch self {
        case .get(_,_,_):
            return headers
        case .post(_,_,_):
            headers.add(.contentType("application/json"))
            return headers
        case .put(_,_,_):
            headers.add(.contentType("application/json"))
            return headers
        case .delete(_,_):
            return headers
        case .request(_,_,_,_):
            return headers
        case .upload(_,_,_,_,_):
            headers.add(.contentType("multipart/form-data"))
            return headers
        }
    }
    
    var multipart: Alamofire.MultipartFormData {
        switch self {
        case .upload(_,_,let method,let parameters,let images):
            let multipart = MultipartFormData()
            if method == .post {
                multipart.append(parameters!.toData, withName: "file", fileName: "file.json", mimeType: "application/json")
            }
            images.forEach {
                let jpegFile = $0.0.jpegData(compressionQuality: 0.75)!
                multipart.append(jpegFile, withName: "image", fileName: "\($0.1).jpeg", mimeType: "image/jpeg")
            }
            return multipart
        default:
            return MultipartFormData()
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var url = try baseURL.asURL().appendingPathComponent(path)
        if !query.isEmpty {
            var components = URLComponents(string: url.absoluteString)
            components?.queryItems = query
            url = (components?.url)!
        }
        let urlEncoded = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var urlRequest = try URLRequest(url: urlEncoded, method: method, headers: headers)
        
        if !parameters.isEmpty {
            urlRequest.httpBody = parameters.toData
            return urlRequest
        }
        return urlRequest
    }
}

extension Encodable {
    var toParameter: Parameters {
        guard let obj = try? JSONEncoder().encode(self) else { return [:] }
        guard let dic = try? JSONSerialization.jsonObject(with: obj, options: []) as? Parameters else { return [:] }
        return dic
    }
}

extension Parameters {
    var toData: Data {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return Data() }
        return data
    }
}

struct Response<T: Codable>: Codable {
    let message: String
    let returnValue: [T]
}

class AquanoteAPI {
    
    static func get(_ app: FunctionsApp, _ path: String, _ query: [URLQueryItem]) async throws -> Data {
        let router = FirestoreRouter.get(app, path, query)
        let request = AF.request(router)
        let response = await request
            .validate(statusCode: 200..<300)
            .serializingData().response
        
        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            print(error.localizedDescription)
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
    
    static func request(router: FirestoreRouter) async throws -> AquanoteResponse<Any>? {
        let request = AF.request(router)
        let response = await request
            .validate(statusCode: 200..<300)
            .serializingData().response
        
        switch response.result {
        case .success(let value):
            return [
                "statusCode": response.response?.statusCode,
                "data": value
            ]
        case .failure(let error):
            print(error.localizedDescription)
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
    
    static func upload(router: FirestoreRouter) async throws -> Data {
        let upload = AF.upload(multipartFormData: router.multipart, with: router)
        
        let response = await upload
            .validate(statusCode: 200..<500)
            .serializingData().response
        
        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            print(error.localizedDescription)
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}
