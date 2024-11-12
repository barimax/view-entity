//
//  RefViewEntity.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import Fluent

public protocol RefViewEntityProtocol: Codable {
    static var fields: [FieldProtocol] { get set }
    static var _schema: String? { get }
    static func refView(refOptions ro: [String:RefOptionField], refViews rw: [String: RefViewProtocol]) -> RefViewProtocol
    static func refView() -> RefViewProtocol
    static func customOptions(db: Database) async throws -> [String:[Option]]?
    var id: UUID? { get set }
}

public extension RefViewEntityProtocol {
    static var _schema: String? { nil }
}

public extension RefViewEntityProtocol where Self: Model {
    static var _schema: String? { Self.schema }
}
