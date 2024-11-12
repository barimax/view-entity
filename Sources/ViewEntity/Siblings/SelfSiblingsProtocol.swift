//
//  SelfSiblingsProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import Fluent

public protocol SelfSiblingProtocol: CommonSiblingProtocol {
    associatedtype M: Model
    static var selfPivotKeyPath: KeyPath<Self, SiblingsProperty<Self, Self, M>> { get }
    static var selfDataKeyPath: ReferenceWritableKeyPath<Self, [Self]> { get }
    static func selfReferenceUpdate(oldEntity: Self, newEntity: Self, database: Database, request: Request) async throws
    static func selfReferenceCreate(newEntity: Self, database: Database, request: Request) async throws
}
public extension SelfSiblingProtocol {
    static func selfReferenceUpdate(oldEntity: Self, newEntity: Self, database: Database, request: Request) async throws {
        try await oldEntity[keyPath: Self.selfPivotKeyPath].load(on: database)
        try await oldEntity[keyPath: Self.selfDataKeyPath].asyncForEach { oldReference in
            try await oldReference[keyPath: Self.selfPivotKeyPath].detach(oldEntity, on: database)
        }
        try await oldEntity[keyPath: Self.selfPivotKeyPath].detach(oldEntity[keyPath: Self.selfDataKeyPath], on: database)
        try await newEntity[keyPath: Self.selfPivotKeyPath].attach(newEntity[keyPath: Self.selfDataKeyPath], on: database)
        try await newEntity[keyPath: Self.selfDataKeyPath].asyncForEach { newReference in
            if try await !newReference[keyPath: Self.selfPivotKeyPath].isAttached(to: newEntity, on: database) {
                try await newReference[keyPath: Self.selfPivotKeyPath].attach(newEntity, on: database)
            }
        }
    }
    static func selfReferenceCreate(newEntity: Self, database: Database, request: Request) async throws {
        try await newEntity[keyPath: Self.selfPivotKeyPath].attach(newEntity[keyPath: Self.selfDataKeyPath], on: database)
        try await newEntity[keyPath: Self.selfDataKeyPath].asyncForEach { newReference in
            try await newReference[keyPath: Self.selfPivotKeyPath].attach(newEntity, on: database)
        }
    }
}
/// If entity had field with reference to the same type
public extension EntityModelProtocol where Self: SelfSiblingProtocol, Self: OptionableEntityProtocol, Self == Self.DTO.M {
    static func updateTransaction(oldEntity: Self, newEntity: Self, database: Database, request: Request) async throws -> EntityCodable {
        try await Self.update(oldEntity: oldEntity, newEntity: newEntity, database: database, request: request)
        try await Self.selfReferenceUpdate(oldEntity: oldEntity, newEntity: newEntity, database: database, request: request)
        return try DTO.fromModel(entity: newEntity)
    }
    static func createTransaction(createdEntity: Self, database: Database, request: Request) async throws -> EntityCodable {
        try await Self.create(newEntity: createdEntity, database: database, request: request)
        var view = await request.isViewLoaded ? try request.entityView : try View<Self>(request: request)
        debugPrint("View: \(view)")
        debugPrint("Current id: \(String(describing: createdEntity.id))")
        let selfReferenceFields = view.fields.filter({field in field.ref is SelfReference<Self>.Type })
        if let id = createdEntity.id {
            for selfField in selfReferenceFields {
                debugPrint("\(selfField.name)")
                let opt: SelectOption = SelectOption(value: id.uuidString, text: "\(createdEntity[keyPath: Self.optionField]  ?? "No string convirtible option.")")
                if(view.refOptions[selfField.name]?.options.isEmpty ?? true){
                    view.refOptions[selfField.name] = RefOptionField(registerName: view.registerName, options: [opt], isButton: true, view: nil)
                }else{
                    view.refOptions[selfField.name]?.options.append(opt)
                }
                debugPrint("Field name: \(selfField.name), Option: \(opt.text)")
            }
        }
        debugPrint("View off: \(view)")
        
        request.setView(newValue: view)
        try await Self.selfReferenceCreate(newEntity: createdEntity, database: database, request: request)
        return try DTO.fromModel(entity: createdEntity)
    }
}
