//
//  SelfReference.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import Fluent

final class SelfReference<T: EntityModelProtocol>: OptionableEntityProtocol where T: OptionableEntityProtocol {
    
    static var optionField: AnyKeyPath { T.optionField }
    static var isButton: Bool { T.isButton }
    static func options(database db: Database) async throws -> [Option] {
        return try await T.options(database: db)
    }
    static func backRefsOptions(fieldName: String, id: UUID, database db: Database) async throws -> [Option] {
        try await T.backRefsOptions(fieldName: fieldName, id: id, database: db)
    }
    static var registerName: String { T.registerName }
    static var schema: String { T.schema }
    static func view(_ v: [String]) async throws -> SimpleViewProtocol? { nil }
    static func customOptions(request: Request) async throws -> [String:[Option]]? { nil }
}
