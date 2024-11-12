//
//  EntityProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Foundation
import Vapor
import FluentKit

public protocol EntityCodable: Codable {}

public protocol EntityProtocol: EntityCodable, MenuProtocol {
    
    static var registerName: String { get }
    static var entityConfiguration: EntityConfiguration { get set }
    
    // Auto completed static prpoerties in extensions
    static var fromFile: Bool { get }
    static var isDateOptimized: Bool { get }
    static var dateOptimizedPropertyName: String? { get }
    static var isDocument: Bool { get }
    
    
    
    static var schema: String { get } // Need for Fluent Model
    // Next properties are required fields for each entity type and no need to be described as entity properties objects
    var id: UUID? { get set }
    var deletedAt: Date? { get set }
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
    // End of requiered properties for model fields
    

    static func loadView(_ r: Request, _ v: [String], full f: Bool) async throws -> ViewProtocol?
    /// Returns entity view by initializing view from request
    static func pureView(_ r: Request) throws -> ViewProtocol
    
//    static func customOptions(request: Request) async throws -> [String:[Option]]?
    
    static func save(request: Request) async throws -> ResponseEncoded
    static func get(request: Request) async throws -> GetResponseEncoded
    static func delete(request: Request, id: UUID, force: Bool) async throws -> DeleteResponseEncoded
    static func recalculate(request: Request, view: ViewProtocol?, triggerFieldName: String?) async throws -> (Encodable, ViewProtocol?)
    
    init()
}

public extension EntityProtocol {
    static var fromFile: Bool { false } // default for regular entity
    static var isDateOptimized: Bool { false } // default for regular entity
    static var dateOptimizedPropertyName: String? { nil } // default for regular entity
    static var isDocument: Bool { false } // default for regular entity
}

