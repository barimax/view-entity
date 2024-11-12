//
//  SimpleViewEntityProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Foundation

public protocol SimpleViewEntityProtocol: SimpleViewProtocol {
    associatedtype T: EntityModelProtocol
}

public extension SimpleViewEntityProtocol {
    var fields: [FieldProtocol] {
        get {
            var fields = T.entityConfiguration.fields
            if !fields.contains(where: { $0.name.lowercased() == "id" }) {
                fields.append(EntityProperty<T, UUID>.id())
            }
            return fields
        }
        set(newValue){
            T.entityConfiguration.fields = newValue
        }
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
