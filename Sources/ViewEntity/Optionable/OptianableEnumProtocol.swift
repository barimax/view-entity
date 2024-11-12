//
//  OptianableEnumProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Fluent

public protocol OptionableEnumProtocol: OptionableProtocol, CaseIterable {
    
    func getName() -> String?
    
    static func prepareEnumMigration(database: Database) async throws -> DatabaseSchema.DataType
}
public extension OptionableEnumProtocol {
    static var isButton: Bool {
        return false
    }
    static var schema: String { "" }
    static func view(_ v: [String]) async throws -> SimpleViewProtocol? { nil }
}

public extension OptionableEnumProtocol where Self: RawRepresentable, Self.RawValue == String {
    static func options(database db: Database) async throws -> [Option] {
        var res: [Option] = []
        if let allCases = Self.allCases as? [Self] {
            for option in allCases {
                if let name = option.getName() {
                    res.append(Option(value: option.rawValue, text: name))
                }
            }
        }
        return res
    }
}
