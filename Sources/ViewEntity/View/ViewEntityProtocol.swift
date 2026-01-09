//
//  ViewEntityProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import Fluent



public protocol ViewEntityProtocol: ViewProtocol, SimpleViewEntityProtocol {
    func responseEncoder(from: [EntityCodable]) -> ResponseEncoded
    func responseEncoder(from: [EntityCodable], lastLimit: Int) -> ResponseEncoded
    func responseEncoder(from: EntityCodable) -> ResponseEncoded
    static func load(req: Request, views: [String], full isFullLoad: Bool) async throws -> View<T>
    static func currentOptions(customOptions: [String : [SelectOption]]?,field: FieldProtocol, view: inout View<T>, database: Database) async throws -> [SelectOption]
}

public extension ViewEntityProtocol {
    
    var searchableDBFields: [String] { T.entityConfiguration.searchableDBFields }
    var recalculateTriggerFields: [String] { [] }
    
    var query: QueryBuilder<T> { T.query(on: self.database) }
    
    private func singleQuery(query q: QueryBuilder<T>) -> QueryBuilder<T> { T.singleQuery(query: q) }
    
    private func first(query: QueryBuilder<T>) async throws -> ResponseEncoded {
        guard let entity = try await query.first() else {
            throw Abort(.notFound)
        }
        return self.responseEncoder(from: entity)
    }

    func decodeRequest(request: Request) async throws -> T {
        try await T.decodeRequest(request: request)
    }
    
    static func currentOptions(customOptions: [String : [SelectOption]]?,field: FieldProtocol, view: inout View<T>, database: Database) async throws -> [SelectOption] {
        if let customOpts = customOptions {
            view.forceServerLoad = true
            if let unwrappedOptions = customOpts[field.name] {
                return unwrappedOptions
            }
        }
        return try await field.ref!.options(database: database)
    }
    
    func get(id: String?) async throws -> ResponseEncoded {
        guard let uuidString = id,
              let uuid = UUID(uuidString: uuidString) else {
            throw Abort(.custom(code: 401, reasonPhrase: "Bad ID."))
        }
        return try await self.first(query: self.singleQuery(query: self.query.filter(FieldKey.id, .equal, uuid)))
    }
    
    
    
    
}

public extension ViewEntityProtocol where T: RecalculateTriggersProtocol {
    var recalculateTriggerFields: [String] { T.recalculateTriggerFields }
}
