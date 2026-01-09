//
//  DTOProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import FluentKit

public protocol DTOProtocol: EntityModelProtocol {
    associatedtype DTO: DTOResponsable
}

/// If entity support DTO transport
/// Decode request from DTO object to entity type
/// Returns DTO object from entity after create and update transactions used in save static method
public extension EntityModelProtocol where Self: DTOProtocol, Self == Self.DTO.M {
    static func decodeRequest(request: Request) async throws -> Self.DTO.M {
        print("[JORO] Decode DTO request.")
        let dto = try request.content.decode(DTO.self)
        return try await dto.toModel(request: request)
    }
    static func createTransaction(createdEntity: Self, database: Database, request: Request, view: inout (any ViewEntityProtocol)?) async throws -> EntityCodable {
        try await Self.create(newEntity: createdEntity, database: database, request: request)
        return try DTO.fromModel(entity: createdEntity)
    }
    static func updateTransaction(oldEntity: Self, newEntity: Self, database: Database, request: Request) async throws -> EntityCodable {
        try await Self.update(oldEntity: oldEntity, newEntity: newEntity, database: database, request: request)
        return try DTO.fromModel(entity: newEntity)
    }
}
