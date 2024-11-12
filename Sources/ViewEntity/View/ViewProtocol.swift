//
//  ViewProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import Fluent
import FluentSQL

public protocol ViewProtocol: SimpleViewProtocol {
    var searchableDBFields: [String] { get }
    var refOptions: [String:RefOptionField] { get set }
    var backRefs: [BackRefs] { get set }
    var refViews: [String: RefViewProtocol] { get set }
    var recalculateTriggerFields: [String] { get }
    var forceServerLoad: Bool { get set }
    var fromFile: Bool { get }
    var isDateOptimized: Bool { get }
    var dateOptimizedPropertyName: String? { get }
    var rowsCount: Int { get set }
    func responseEncoded() -> ResponseEncoded
    static func load(req: Request, views: [String], full isFullLoad: Bool) async throws -> ViewProtocol
    var request: Request { get }
    var database: Database { get }
    
//    func getAll(withChildren: Bool, withDeleted: Bool, allDateOptimized: Bool) async throws -> ResponseEncoded
    func get(id: String?) async throws -> ResponseEncoded
//    func get(id: String) async throws -> EntityProtocol?
//    func get(request: Request) async throws -> GetResponseEncoded
//    func find(query: [String:String], withDeleted: Bool) async throws -> ResponseEncoded
//    func find(query: [String:String], withDeleted: Bool) async throws -> [EntityProtocol]
//    func search(query: String, withDeleted: Bool) async throws -> ResponseEncoded
//    func restore() async throws
    
    init(request: Request, loadedViewsRegisterNames: [String], transactionDB: Database?) async throws
}

public extension ViewProtocol {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ViewCodingKeys.self)
        try container.encode(singleName, forKey: .singleName)
        try container.encode(pluralName, forKey: .pluralName)
        try container.encode(fields.map { EncodableWrapper($0) }, forKey: .fields)
        try container.encode(registerName, forKey: .registerName)
        try container.encode(refOptions, forKey: .refOptions)
        try container.encode(backRefs, forKey: .backRefs)
        try container.encode(titleFieldName, forKey: .titleFieldName)
        try container.encode(recalculateTriggerFields, forKey: .recalculateTriggerFields)
        try container.encode(forceServerLoad, forKey: .forceServerLoad)
        try container.encode(fromFile, forKey: .fromFile)
        try container.encode(isDateOptimized, forKey: .isDateOptimized)
        try container.encode(dateOptimizedPropertyName, forKey: .dateOptimizedPropertyName)
        try container.encode(rowsCount, forKey: .rowsCount)
        try container.encode(isDocument, forKey: .isDocument)
        let wrapped = self.refViews.map{ (k: String, v: RefViewProtocol) in
            return (k,EncodableWrapper(v))
        }
        try container.encode(Dictionary(uniqueKeysWithValues: wrapped), forKey: .refViews)
    }
    
    
}
