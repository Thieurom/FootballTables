//
//  Sectionable.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

protocol Sectionable: Hashable {
    associatedtype Item: Hashable
    var items: [Item] { get }
}
