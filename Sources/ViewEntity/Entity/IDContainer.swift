//
//  IDContainer.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Foundation
import Vapor

public struct IDContainer: Codable {
    public let id: String?
    public var optionalUUID: UUID? {
        if let idString = self.id {
            return UUID(idString)
        }
        return nil
    }
    public func uuid() throws -> UUID {
        guard let uuid = self.optionalUUID else {
            throw Abort(.badRequest)
        }
        return uuid
    }
    
    public init?(id: UUID?){
        guard let uuid = id?.uuidString else{
            return nil
        }
        self.id = uuid
    }
    
    public init?(id: String?) {
        guard let idString = id else {
            return nil
        }
        self.id = idString
    }
    public init(id: String) {
        self.id = id
    }
    public init(uuid: UUID){
        self.id = uuid.uuidString
    }
}
