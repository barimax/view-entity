//
//  SiblingsProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//
import Vapor
import Fluent

public protocol NonSelfSiblingProtocol: CommonSiblingProtocol {
    static var pivotSchemas: [String: String] { get }
    static var siblingsParents: [String: String] { get }
}
public protocol SiblingsProtocol: NonSelfSiblingProtocol  {
    associatedtype FROM: EntityModelProtocol
    static func updateSibling<ON: EntityModelProtocol, M: Model>(pivotKeyPath: KeyPath<FROM, SiblingsProperty<FROM, ON, M>>, dataKeyPath: ReferenceWritableKeyPath<FROM, [ON]>, oldEntity: FROM, newEntity: FROM, database: Database, request: Request) async throws
    static func createSibling<ON: EntityModelProtocol, M: Model>(pivotKeyPath: KeyPath<Self, SiblingsProperty<FROM, ON, M>>, dataKeyPath: ReferenceWritableKeyPath<FROM, [ON]>, newEntity: FROM, database: Database, request: Request) async throws
    static func filterSiblings(filter: [String: [UUID]], query: QueryBuilder<Self>) -> QueryBuilder<Self>
}

public extension SiblingsProtocol {
    static func updateSibling<ON: EntityModelProtocol, M: Model>(pivotKeyPath: KeyPath<FROM, SiblingsProperty<FROM, ON, M>>, dataKeyPath: ReferenceWritableKeyPath<FROM, [ON]>, oldEntity: FROM, newEntity: FROM, database: Database, request: Request) async throws {
        try await oldEntity[keyPath: pivotKeyPath].load(on: database)
        try await oldEntity[keyPath: pivotKeyPath].detach(oldEntity[keyPath: dataKeyPath], on: database)
        try await newEntity[keyPath: pivotKeyPath].attach(newEntity[keyPath: dataKeyPath], on: database)
    }
    static func createSibling<ON: EntityModelProtocol, M: Model>(pivotKeyPath: KeyPath<FROM, SiblingsProperty<FROM, ON, M>>, dataKeyPath: ReferenceWritableKeyPath<FROM, [ON]>, newEntity: FROM, database: Database, request: Request) async throws {
        try await newEntity[keyPath: pivotKeyPath].attach(newEntity[keyPath: dataKeyPath], on: database)
    }
}

/// Defaults parentFieldKeys when entity has no reference field to self
public extension EntityModelProtocol where Self: NonSelfSiblingProtocol {
    static var parentFiledsKeys: [String : String] {
        Self.siblingsParents
    }
}
public extension EntityModelProtocol where Self: SiblingsProtocol {
    static func filterQuery(filter: [String : [UUID]], query: QueryBuilder<Self>) -> QueryBuilder<Self> {
        Self.filterSiblings(filter: filter, query: query)
    }
}
