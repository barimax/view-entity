//
//  RecalculateEntityExtension.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import Fluent

/// If entity is recalclatable and conforms to DTO protocol
/// Calls entity recalculate static method after entity creation with transaction database object supplied
/// Returns DTO object from entity after create and update transactions used in save static method

public extension EntityModelProtocol where Self == Self.DTO.M, Self: RecalculateProtocol {
    
    static func createTransaction(createdEntity: Self, database: Database, request: Request, view: inout (any ViewEntityProtocol)?) async throws -> EntityCodable {
        try await Self.create(newEntity: createdEntity, database: database, request: request)
        let dto = try DTO.fromModel(entity: createdEntity)
        let (recalculated, _, _) = try await Self.recalculate(request: request, dto: dto)
        return recalculated as EntityCodable

    }
    static func updateTransaction(oldEntity: Self, newEntity: Self, database: Database, request: Request) async throws -> EntityCodable {
        try await Self.update(oldEntity: oldEntity, newEntity: newEntity, database: database, request: request)
        return try DTO.fromModel(entity: newEntity)
    }
    
    static func recalculate(request: Request) async throws -> (Encodable, [FieldProtocol]?, [String: RefOptionField]?) {
        let dto = try request.content.decode(DTO.self)
        return try await Self.recalculate(request: request, dto: dto)
    }
}
public extension EntityModelProtocol where Self: RecalculateTriggersProtocol {
    static var recalculateTriggerFields: [String] { triggerFields }
}

/// If entity conforms to RecalculateProtocol but theres no DTO
/// Calls entity recalculate method without DTO ( dto: nil)
public extension EntityModelProtocol where Self: RecalculateProtocol {
    static func recalculate(request: Request, view: (any ViewEntityProtocol)?, triggerFieldName: String?) async throws -> (Encodable, [any FieldProtocol]?, [String: RefOptionField]?) {
        return try await Self.recalculate(request: request, dto: nil)
    }
}
