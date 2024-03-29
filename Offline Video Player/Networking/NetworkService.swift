//
//  NetworkManager.swift
//  Offline Video Player
//
//  Created by Maneesh M on 28/02/23.
//

import Foundation
import Combine



protocol NetworkService {
    func fetch<T: Decodable>(_ request: NetworkRequest) -> AnyPublisher<T, Error>
}

protocol NetworkRequest {
    var path: String { get }
    var mockPath: String? { get }
    var url: URL { get }
    var shouldStoreResponse: Bool { get }
}
extension NetworkRequest {
    var url: URL {
        URL(string: path)!
    }
}

enum NetworkError: Error {
    case statusCode(Int)
}


final class URLSessionNetworkService: NetworkService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(_ endpoint: NetworkRequest) -> AnyPublisher<T, Error> {
        let url = endpoint.url
        let request = URLRequest(url: url)
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    throw NetworkError.statusCode(httpResponse.statusCode)
                }
                CacheManager.cacheResponse(data, for: url)
                return data
            }.catch({ error -> AnyPublisher<Data, Error> in
                if let cachedData = CacheManager.getCachedResponse(for: url){
                    return Just(cachedData).setFailureType(to: Error.self).eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            })
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

final class MockNetworkService: NetworkService {
    func fetch<T>(_ request: NetworkRequest) -> AnyPublisher<T, Error> where T : Decodable {
        return getMockData(from: request.mockPath)
    }
}

extension NetworkService {

    
    func getMockData<T:Decodable>(from fileName: String?, bundle: Bundle = .main) -> AnyPublisher<T, Error> {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            return Fail(error: NSError(domain: "com.my.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "JSON file not found."]))
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

}




struct CacheManager {
    private static let keyPrefix = "com.myapp.url_cache_"
    static func getCachedResponse(for url: URL) -> Data? {
        let key = Self.keyPrefix + url.absoluteString
        return UserDefaults.standard.data(forKey: key)
    }
    
    static func cacheResponse(_ data: Data, for url: URL) {
        let key = Self.keyPrefix + url.absoluteString
        UserDefaults.standard.set(data, forKey: key)
    }
    
    static func clearCache() {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix(Self.keyPrefix) {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
}
