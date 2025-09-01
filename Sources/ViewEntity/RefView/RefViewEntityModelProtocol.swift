//
//  RefViewEntityModelProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Fluent

public protocol RefViewEntityModelProtocol: RefViewEntityProtocol {
    associatedtype F: RefViewEntityProtocol
    static var isDocument: Bool { get }
    static var registerName: String { get }
}
public extension RefViewEntityModelProtocol {
    static var isDocument: Bool { false }
    static func refView(refOptions ro: [String:RefOptionField], refViews rw: [String: RefViewProtocol]) -> RefViewProtocol {
        RefView<Self>.load(refOptions: ro, refViews: rw)
    }
    static func refView() -> RefViewProtocol {
        RefView<Self>()
    }
    static func customOptions(db: Database) async throws -> [String:[SelectOption]]? { nil }
}
