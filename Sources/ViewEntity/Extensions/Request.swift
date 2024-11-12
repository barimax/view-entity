//
//  Request.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import FluentKit


struct DBConfigurationKey: StorageKey {
    typealias Value = DatabaseID
}

struct ViewKey: StorageKey {
    typealias Value = ViewProtocol
}

struct EntityTypeKey: StorageKey {
    typealias Value = EntityProtocol.Type
}


public extension Request {
    internal var appConfiguration: AppConfiguration {
        self.application.appConfiguration
    }
    
    var entityView: ViewProtocol {
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
    
    var entityType: EntityProtocol.Type {
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
        guard let registerName = self.parameters.get("registerName") else {
            throw Abort(.badRequest)
        }
        self.storage[EntityTypeKey.self] = self.application.register.get(key: registerName)
    }
    
    func setView(newValue: ViewProtocol) {
        self.storage[ViewKey.self] = newValue
    }
    
   
    
    var databaseID: DatabaseID? {
            get {
                self.storage[DBConfigurationKey.self]
            }
            set {
                self.storage[DBConfigurationKey.self] = newValue
            }
        }
    func companyDatabase() throws -> Database  {
        guard let databaseID = self.databaseID else {
            throw Abort(.badRequest)
        }
        return self.db(databaseID)
    }
}
