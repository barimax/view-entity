//
//  SelfReference.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import Fluent

public final class SelfReference<T: EntityModelProtocol>: OptionableEntityProtocol where T: OptionableEntityProtocol {
    
    public static var optionField: AnyKeyPath { T.optionField }
    public static var isButton: Bool { T.isButton }
    public static func options(database db: Database) async throws -> [SelectOption] {
        return try await T.options(database: db)
    }
    public static func backRefsOptions(fieldName: String, id: UUID, database db: Database) async throws -> [SelectOption] {
        try await T.backRefsOptions(fieldName: fieldName, id: id, database: db)
    }
    public static var registerName: String { T.registerName }
    public static var schema: String { T.schema }
    public static func view(_ v: [String]) async throws -> (any SimpleViewEntityProtocol)? { nil }
    public static func customOptions(request: Request) async throws -> [String:[SelectOption]]? { nil }
}
