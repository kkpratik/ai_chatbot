//
//  AppConfig.swift
//  ChatWithAI
//
//  Created by Pratik Parmar on 07/05/26.
//
import Foundation

struct AppConfig {
    static var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["OPENROUTER_API_KEY"] as? String else {
            fatalError("API Key not found")
        }
        return key
    }
}
