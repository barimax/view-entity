//
//  ViewEntityProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import Fluent



public protocol ViewEntityProtocol: SimpleViewEntityProtocol {
    var searchableDBFields: [String] { get }
    var refOptions: [String:RefOptionField] { get set }
    var backRefs: [BackRefs] { get set }
    var refViews: [String: RefViewProtocol] { get set }
    var recalculateTriggerFields: [String] { get }
    var forceServerLoad: Bool { get set }
    var fromFile: Bool { get }
    var isDateOptimized: Bool { get }
    var dateOptimizedPropertyName: String? { get }
    var rowsCount: Int { get set }
    func responseEncoded() -> ResponseEncoded
    var request: Request { get }
    var database: Database { get }
    
    func get(id: String?) async throws -> ResponseEncoded
    init(request: Request, loadedViewsRegisterNames: [String], transactionDB: Database?) async throws
    
    func responseEncoder(from: [EntityCodable]) -> ResponseEncoded
    func responseEncoder(from: [EntityCodable], lastLimit: Int) -> ResponseEncoded
    func responseEncoder(from: EntityCodable) -> ResponseEncoded
    static func load(req: Request, views: [String], full isFullLoad: Bool) async throws -> View<T>
    static func currentOptions(customOptions: [String : [SelectOption]]?,field: FieldProtocol, view: inout View<T>, database: Database) async throws -> [SelectOption]
}

public extension ViewEntityProtocol {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ViewCodingKeys.self)
        try container.encode(singleName, forKey: .singleName)
        try container.encode(pluralName, forKey: .pluralName)
        try container.encode(fields.map { EncodableWrapper($0) }, forKey: .fields)
        try container.encode(registerName, forKey: .registerName)
        try container.encode(refOptions, forKey: .refOptions)
        try container.encode(backRefs, forKey: .backRefs)
        try container.encode(titleFieldName, forKey: .titleFieldName)
        try container.encode(recalculateTriggerFields, forKey: .recalculateTriggerFields)
        try container.encode(forceServerLoad, forKey: .forceServerLoad)
        try container.encode(fromFile, forKey: .fromFile)
        try container.encode(isDateOptimized, forKey: .isDateOptimized)
        try container.encode(dateOptimizedPropertyName, forKey: .dateOptimizedPropertyName)
        try container.encode(rowsCount, forKey: .rowsCount)
        try container.encode(isDocument, forKey: .isDocument)
        let wrapped = self.refViews.map{ (k: String, v: RefViewProtocol) in
            return (k,EncodableWrapper(v))
        }
        try container.encode(Dictionary(uniqueKeysWithValues: wrapped), forKey: .refViews)
    }
    
    var searchableDBFields: [String] { T.entityConfiguration.searchableDBFields }
    var recalculateTriggerFields: [String] { T.recalculateTriggerFields }
    
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


