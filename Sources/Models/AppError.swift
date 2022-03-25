//
//  AppError.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 07/03/2022.
//

import Foundation

public struct AppError: Error, Equatable {
    public let message: String

    public init(message: String) {
        self.message = message
    }
}
