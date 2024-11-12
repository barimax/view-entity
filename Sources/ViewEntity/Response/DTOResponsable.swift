//
//  DTOResponsableProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor

public protocol DTOResponsable: EntityCodable, Content {
    associatedtype M: DTOProtocol
    func toModel(request: Request) async throws -> M
    static func fromModel(entity: M) throws -> Self
}
