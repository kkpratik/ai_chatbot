//
//  ChatService.swift
//  ChatWithAI
//
//  Created by Pratik Parmar on 24/04/26.
//

import Foundation

private let apiKey = ""

enum ServiceError: Error {
    case unsupportedQuery
    case noResponseFound
    case unrecognizedInput
    
    var message: String {
        switch self {
            
        case .unsupportedQuery:
            "Sorry!, your query is unsupported."
        case .noResponseFound:
            "Sorry!, i could not find any response for your query."
        case .unrecognizedInput:
            "Sorry!, i could not reconize this input."
        }
    }
}

struct ServiceConfig {
    static let URLString = "https://openrouter.ai/api/v1/chat/completions"
    static let headers: [String: String] = [
        "Authorization": "Bearer \(apiKey)",
        "Content-Type": "application/json"
    ]
}

class ChatService {
    
    var networkService: Networking
    
    init(networkService: Networking) {
        self.networkService = networkService
    }
    
    func generateResponse(from messages: [Message]) async throws -> Message {
        
        guard let endpoint = createEndpoint(from: messages) else {
            throw ServiceError.noResponseFound
        }
        
        let data = try await networkService.request(endpoint)
        
        guard let text = parseResponse(data) else {
            throw ServiceError.noResponseFound
        }
        
        return Message(text: text, sender: .ai)
    }
    
    private func createEndpoint(from messages: [Message]) -> Endpoint? {
        
        guard let url = URL(string: ServiceConfig.URLString),
              let body = createRequestBody(from: messages)
        else { return nil }
        
        return Endpoint(
            url: url,
            method: "POST",
            headers: ServiceConfig.headers,
            body:body
        )
    }
    
    private func createRequestBody(from messages: [Message]) -> Data? {
        let mapped = mapMessages(messages: messages)
        let body: [String : Any] = [
            "model": "openrouter/auto",
            "messages": mapped
        ]
        return try? JSONSerialization.data(withJSONObject: body)
    }
    
    private func mapMessages(messages: [Message]) -> [[String: String]] {
        messages.map { message in
            [
                "role": message.sender == .user ? "user" : "assistant",
                "content": message.text
            ]
        }
    }
    
    private func parseResponse(_ data: Data) -> String? {
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String
        else {
            return nil
        }
        
        return content
    }
}

