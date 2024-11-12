//
//  RecalculateEntityProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import FluentKit

public protocol RecalculateProtocol: DTOProtocol {
    static var recalculateTriggerFieldsList: [String] { get }
    static func recalculate(request: Request, view: ViewProtocol?, triggerFieldName: String?, dto: DTO?) async throws -> (DTO, ViewProtocol?)
}
