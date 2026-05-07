//
//  ChatViewModel.swift
//  ChatWithAI
//
//  Created by Pratik Parmar on 24/04/26.
//

import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    
    @Published var messages: [Message]
    @Published var inputString = ""
    @Published var isLoading = false
    let chatService: ChatService
    var canSendMessage: Bool {
        !isLoading && isValid()
    }
    
    init(messages: [Message], chatService: ChatService) {
        self.messages = messages
        self.chatService = chatService
    }
    
    func sendMessage()  {
        Task {
            await performSendMessage()
        }
    }
    
    func performSendMessage() async {
        guard canSendMessage else { return }
        let message = Message(text: inputString, sender: .user)
        messages.append(message)
        inputString = ""
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let reply = try await chatService.generateResponse(from: messages)
            messages.append(reply)
        } catch {
            messages.append(getMessage(from: error))
        }
    }
    
    func getMessage(from error: Error) -> Message {
        let text: String
        
        if let serviceError = error as? ServiceError {
            text = serviceError.message
        } else if let networkError = error as? NetworkError {
            text = networkError.message
        } else {
            text = "Something went wrong. Please try again."
        }
        
        return Message(text: text, sender: .ai)
    }
    
    func isValid() -> Bool {
        !inputString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
