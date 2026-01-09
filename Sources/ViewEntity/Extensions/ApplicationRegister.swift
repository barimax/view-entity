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
    func initModelsRegister(types: [any EntityModelProtocol.Type]) {
        var register = Register()
        register.add(types: types)
        self.storage[RegisterKey.self] = register
    }
}
public struct Register: Sendable {
    private var store: [any EntityModelProtocol.Type] = []
    
    public var all: [any EntityModelProtocol.Type] {
        self.store
    }
    
    public mutating func add(type: any EntityModelProtocol.Type) {
        self.store.append(type)
    }
    
    public mutating func add(types: [any EntityModelProtocol.Type]) {
        self.store.append(contentsOf: types)
    }
    
    public func get(key: String) -> (any EntityModelProtocol.Type)? {
        self.store.first(where: { $0.registerName == key })
    }
}
