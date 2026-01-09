//
//  SimpleViewEntityProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Foundation

public protocol SimpleViewEntityProtocol: Encodable, Sendable {
    associatedtype T: EntityModelProtocol
    var fields: [FieldProtocol] { get }
    var registerName: String { get }
    var singleName: String { get }
    var pluralName: String { get }
    var titleFieldName: String { get }
    var loadedViewsRegisterNames: [String] { get set }
    var isDocument: Bool { get }
}

public extension SimpleViewEntityProtocol {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ViewCodingKeys.self)
        try container.encode(singleName, forKey: .singleName)
        try container.encode(pluralName, forKey: .pluralName)
        try container.encode(fields.map { EncodableWrapper($0) }, forKey: .fields)
        try container.encode(registerName, forKey: .registerName)
        try container.encode(titleFieldName, forKey: .titleFieldName)
        try container.encode(isDocument, forKey: .isDocument)
    }
    
    var fields: [FieldProtocol] {
        get {
            var fields = T.entityConfiguration.fields
            if !fields.contains(where: { $0.name.lowercased() == "id" }) {
                fields.append(EntityProperty<T, UUID>.id())
            }
            return fields
        }
//        set(newValue){
//            T.entityConfiguration.fields = newValue
//        }
    }
    var fromFile: Bool { T.fromFile }
    var isDateOptimized: Bool { T.isDateOptimized }
    var dateOptimizedPropertyName: String? { T.dateOptimizedPropertyName }
    var registerName: String { T.registerName }
    var singleName: String { T.entityConfiguration.singleName }
    var pluralName: String { T.entityConfiguration.pluralName }
    var titleFieldName: String { T.entityConfiguration.titleFieldName }
    var isDocument: Bool { T.isDocument }
    
}
