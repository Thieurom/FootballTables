//
//  StoreViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

public protocol StoreViewState: Equatable {
    associatedtype State
    init(state: State)
}
