//
//  OptionableEntityProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//
import Foundation
import Vapor
import Fluent
import SwiftDate


protocol OptionableEntityProtocol: OptionableProtocol  {
    static var optionField: AnyKeyPath { get }
    static func backRefsOptions(fieldName: String, id: UUID, database db: Database) async throws -> [Option]
//    var id: UUID? { get set }
}
extension OptionableEntityProtocol where Self: EntityModelProtocol  {
    static func view(_ v: [String]) async throws -> SimpleViewProtocol? {
        return SimpleView<Self>(loadedViewsRegisterNames: v)
    }
    static func options(database db: Database) async throws -> [Option] {
        return try await Self.query(on: db)
            .all()
            .filter { $0.id != nil }
            .map {
                let text = $0[keyPath: Self.optionField] is Date ? ($0[keyPath: Self.optionField] as! Date).toFormat("dd.MM.yyyy г.") : "\($0[keyPath: Self.optionField] ?? "No string convirtible option.")"
                return Option(value: $0.id!.uuidString, text: text)
            }
    }
    static var isButton: Bool {
        return true
    }
    static func backRefsOptions(fieldName: String, id: UUID, database db: Database) async throws -> [Option] {
        guard let field = Self.entityConfiguration.fields.first(where: { field in field.name == fieldName}) else {
            throw Abort(.badRequest, reason: "Грешка в името на полето.")
        }
        let fieldKey = FieldKey.string(field.keyField)
        return try await Self.query(on: db)
            .filter(fieldKey, DatabaseQuery.Filter.Method.equal, id)
            .all()
            .filter { $0.id != nil }
            .map {
                let text = $0[keyPath: Self.optionField] is Date ? ($0[keyPath: Self.optionField] as! Date).toFormat("dd.MM.yyyy г.") : "\($0[keyPath: Self.optionField] ?? "No string convirtible option.")"
                return Option(value: $0.id!.uuidString, text: text)
            }
    }
    
}

extension OptionableEntityProtocol where Self: SelfSiblingProtocol {
    static func backRefsOptions(fieldName: String, id: UUID, database db: Database) async throws -> [Option] {
        guard let field = Self.entityConfiguration.fields.first(where: { field in field.name == fieldName}) else {
            throw Abort(.badRequest, reason: "Грешка в името на полето.")
        }
        guard let result = try await Self.query(on: db).filter(FieldKey.id, .equal, id).first() else {
            throw Abort(.badRequest, reason: "Missing type.")
        }
        return try await result[keyPath: selfPivotKeyPath].get(on: db).map {
            let text = $0[keyPath: Self.optionField] is Date ? ($0[keyPath: Self.optionField] as! Date).toFormat("dd.MM.yyyy г.") : "\($0[keyPath: Self.optionField] ?? "No string convirtible option.")"
                return Option(value: $0.id!.uuidString, text: text)
            }
    }
}