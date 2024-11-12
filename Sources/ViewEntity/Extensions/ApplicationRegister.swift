//
//  ApplicationRegister.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//
import Vapor

struct RegisterKey: StorageKey {
    typealias Value = Register
}

public extension Application {
    var register: Register {
        get throws {
            guard let register = self.storage[RegisterKey.self] else {
                throw Abort(.badRequest)
            }
            return register
        }
        
        
    }
    func initModelsRegister(types: [EntityProtocol.Type]) {
        var register = Register()
        register.add(types: types)
        self.storage[RegisterKey.self] = register
    }
}
public struct Register: Sendable {
    private var store: [EntityProtocol.Type] = []
    
    public var all: [EntityProtocol.Type] {
        self.store
    }
    
    public mutating func add(type: EntityProtocol.Type) {
        self.store.append(type)
    }
    
    public mutating func add(types: [EntityProtocol.Type]) {
        self.store.append(contentsOf: types)
    }
    
    public func get(key: String) -> EntityProtocol.Type? {
        self.store.first(where: { $0.registerName == key })
    }
}
