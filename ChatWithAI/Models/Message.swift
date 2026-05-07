//
//  Message.swift
//  ChatWithAI
//
//  Created by Pratik Parmar on 24/04/26.
//

import Foundation

enum Sender: String, Equatable {
    case user = "user"
    case ai = "assistant"
}

struct Message: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let sender: Sender
    let timestamp = Date()
}
