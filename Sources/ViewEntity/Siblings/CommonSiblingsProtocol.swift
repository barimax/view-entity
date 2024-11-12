//
//  CommonSiblingsProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Fluent
import Vapor

protocol CommonSiblingProtocol: DTOProtocol {
    static func siblingLoader<ON: EntityModelProtocol>(on: ON.Type, value:[IDContainer]?, database: Database) async throws -> [ON]
}
extension CommonSiblingProtocol {
    static func siblingLoader<ON: EntityModelProtocol>(on: ON.Type, value:[IDContainer]?, database: Database) async throws -> [ON] {
        let containers = value ?? []
        if containers.isEmpty {
            return []
        }
        return try await ON.query(on: database).group(.or) { group in
            for idContainer in containers {
                try group.filter(FieldKey(stringLiteral: "id"), .equal, idContainer.uuid())
            }
        }.all()
    }
}
