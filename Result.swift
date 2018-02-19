//
//  APIResult.swift
//  IQVIAAuthService
//
//  Created by Steve Foster on 11/29/17.
//  Copyright © 2018 IQVIA, Inc. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)
}

public typealias APIResult<T> = (Result<T>) -> Void

