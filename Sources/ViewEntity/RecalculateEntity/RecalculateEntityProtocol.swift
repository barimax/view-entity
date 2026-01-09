//
//  RecalculateEntityProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import FluentKit

public protocol RecalculateTriggersProtocol {
    static var recalculateTriggerFields: [String] { get }
}

public protocol RecalculateProtocol: RecalculateTriggersProtocol, DTOProtocol {
    static func recalculate(request: Request, view: ViewProtocol?, triggerFieldName: String?, dto: DTO?) async throws -> (DTO, ViewProtocol?)
}
