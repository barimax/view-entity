//
//  Request.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import FluentKit
import TypesLib


struct DBConfigurationKey: StorageKey {
    typealias Value = DatabaseID
}

struct ViewKey: StorageKey {
    typealias Value = any ViewEntityProtocol
}

struct EntityTypeKey: StorageKey {
    typealias Value = any EntityModelProtocol.Type
}


public extension Request {
    internal var appConfiguration: Configuration {
        self.application.appConfiguration
    }
    
    var entityView: any ViewEntityProtocol {
        get throws {
            guard let view = self.storage[ViewKey.self] else {
                throw Abort(.badRequest)
            }
            return view
        }
        
        
    }
    
    var isViewLoaded: Bool {
        self.storage[ViewKey.self] != nil
    }
    
    var entityType: any EntityModelProtocol.Type {
        get throws {
            guard let entityType = self.storage[EntityTypeKey.self] else {
                throw Abort(.badRequest)
            }
            return entityType
        }
    }
    
    func loadAll() async throws {
        try loadEntityType()
        self.storage[ViewKey.self] = try await self.entityType.loadView(self, [], full: false)
    }
    
    func loadEntityType() throws {
        guard let registerName = self.parameters.get("registerName"),
              let entityType = try? self.application.register.get(key: registerName) else {
            throw Abort(.badRequest)
        }
        self.storage[EntityTypeKey.self] = entityType
    }
    
    func setView(newValue: any ViewEntityProtocol) {
        self.storage[ViewKey.self] = newValue
    }
    
    func requireCompanyDatabase() throws -> Database  {
        guard let databaseID = self.authServer.companyDatabaseID else {
            throw Abort(.badRequest)
        }
        return self.db(DatabaseID(string: databaseID))
    }
}
