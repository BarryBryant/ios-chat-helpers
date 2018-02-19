//
//  DialogFlow.swift
//  IQVIA Voice Assistant
//
//  Created by Barry Bryant on 2/15/18.
//  Copyright © 2018 BarryBryant. All rights reserved.
//

import Foundation
import IQVIAAuthService

enum DialogFlowError: LocalizedError {
    case badEndpoint
    case badResponse
    
    var localizedDescription: String {
        switch self {
        case .badEndpoint:
            return NSLocalizedString("The API AI endpoint being used is invalid", comment: "The API AI endpoint being used is invalid")
        case .badResponse:
            return NSLocalizedString("An error occured parsing the response", comment: "Error parsing response")
        }
    }
}

enum DialogFlow {
    
    static func handleSpeech(utterance: String, completion: @escaping APIResult<DialogFlowResponse>) {
        let endpoint = "https://api.dialogflow.com/v1/query?v=20150910"
        guard let endpointURL = URL(string: endpoint) else {
            completion(.failure(DialogFlowError.badEndpoint))
            return
        }
        
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.addValue("Bearer API_KEY", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: String] = ["lang": "en",
                                      "query": utterance,
                                      "sessionId": "12345",
                                      "timezone": "America/New_York"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data
            else {
                completion(.failure(DialogFlowError.badResponse))
                return
            }
            let decoder = JSONDecoder()
            let responseObject = try? decoder.decode(DialogFlowResponse.self, from: data)
            if let dialogFlowResponse = responseObject {
                completion(.success(dialogFlowResponse))
            } else {
                completion(.failure(DialogFlowError.badResponse))
            }
        }
        
        task.resume()
    }
    
}

