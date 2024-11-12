//
//  IDContainer.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Foundation
import Vapor

struct IDContainer: Codable {
    let id: String?
    var optionalUUID: UUID? {
        if let idString = self.id {
            return UUID(idString)
        }
        return nil
    }
    func uuid() throws -> UUID {
        guard let uuid = self.optionalUUID else {
            throw Abort(.badRequest)
        }
        return uuid
    }
    
    init?(id: UUID?){
        guard let uuid = id?.uuidString else{
            return nil
        }
        self.id = uuid
    }
    
    init?(id: String?) {
        guard let idString = id else {
            return nil
        }
        self.id = idString
    }
    init(id: String) {
        self.id = id
    }
    init(uuid: UUID){
        self.id = uuid.uuidString
    }
}
