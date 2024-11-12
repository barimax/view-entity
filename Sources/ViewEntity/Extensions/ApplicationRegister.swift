//
//  ApplicationRegister.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//
import Vapor

public extension Application {
    var register: Register {
        Register()
    }
}
public struct Register {
    private var store: [EntityProtocol.Type] = []
    
    var all: [EntityProtocol.Type] {
        self.store
    }
    
    mutating func add(type: EntityProtocol.Type) {
        self.store.append(type)
    }
    
    mutating func add(types: [EntityProtocol.Type]) {
        self.store.append(contentsOf: types)
    }
    
    func get(key: String) -> EntityProtocol.Type? {
        self.store.first(where: { $0.registerName == key })
    }
}
