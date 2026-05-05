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
        guard canSendMessage else { return }
        let message = Message(text: inputString, sender: .user)
        messages.append(message)
        inputString = ""

        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let reply = try await chatService.generateResponse(from: messages)
                messages.append(reply)
            } catch {
                messages.append(getMessage(from: error))
            }
        }
    }
    
    func getMessage(from error: Error) -> Message {
        if let serviceError = error as? ServiceError {
            return Message(text: serviceError.message, sender: .ai)
        } else {
            return Message(text: "Something went wrong. Please try again", sender: .ai)
        }
    }
    
    func isValid() -> Bool {
        !inputString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
