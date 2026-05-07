//
//  NetworkManager.swift
//  ChatWithAI
//
//  Created by Pratik Parmar on 26/04/26.
//

import Foundation

enum NetworkError: Error, Equatable {
    case invalidUrl
    case invalidRequest
    case notFound
    case unauthorised
    case timeOut
    
    var message: String {
        switch self {
        case .invalidUrl:
            return "Invalid server URL."
        case .invalidRequest:
            return "Something went wrong with the request."
        case .notFound:
            return "The requested AI service was not found."
        case .unauthorised:
            return "Authorization failed. Please check the API key."
        case .timeOut:
            return "The request timed out. Please try again."
        }
    }
}

struct Endpoint {
    let url: URL
    let method: String
    let headers: [String: String]
    let body: Data?
}

protocol Networking {
    func request(_ endpoint: Endpoint) async throws -> Data
}

class NetworkManager: Networking {
    func request(_ endpoint: Endpoint) async throws -> Data {
        
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method
        request.httpBody = endpoint.body
        
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidRequest
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 401:
            throw NetworkError.unauthorised
        case 404:
            throw NetworkError.notFound
        case 408:
            throw NetworkError.timeOut
        default:
            throw NetworkError.invalidRequest
        }
    }
}
