//
//  DialogFlowResponse.swift
//  IQVIA Voice Assistant
//
//  Created by Barry Bryant on 2/14/18.
//  Copyright © 2018 BarryBryant. All rights reserved.
//

import Foundation

struct DialogFlowResponse: Codable {
    var id: String
    var timestamp: String
    var lang: String
    var result: DialogFlowResult
    var status: DialogFlowStatus
}

struct DialogFlowResult: Codable {
    var actionIncomplete: Bool
    var parameters: [String: String]
    var metadata: DialogFlowMetadata
    var fulfillment: DialogFlowFulfillment
}

struct DialogFlowMetadata: Codable {
    var intentName: String
}

struct DialogFlowFulfillment: Codable {
    var speech: String
}

struct DialogFlowStatus: Codable {
    var code: Int
    var errorType: String
    var webhookTimedOut: Bool
}

extension DialogFlowResponse {
    var intent: Intent? {
        return Intent(rawValue: result.metadata.intentName)
    }
    
    var actionIncomplete: Bool {
        return result.actionIncomplete
    }
    
    var botResponseSpeech: String {
        return result.fulfillment.speech
    }
    
    var hasBotSpeech: Bool {
        return !botResponseSpeech.isEmpty
    }
}
