//
//  OptionableProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Fluent

protocol OptionableProtocol {
    static var schema: String { get }
    static var isButton: Bool { get }
    static func options(database db: Database) async throws -> [Option]
    static var registerName: String { get }
    static func view(_ v: [String]) async throws -> SimpleViewProtocol?
}
