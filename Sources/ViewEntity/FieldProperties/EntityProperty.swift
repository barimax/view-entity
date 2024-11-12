//
//  EntityProperty.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//
import Fluent

public struct EntityProperty<T, V>: FieldProtocol where T: Model, V: Codable, V: Sendable {
    public let keyField: String
    public let name: String
    public var fieldType: FieldType
    public let dataType: DataType
    public let label: String
    public var required: Bool
    public var disabled: Bool
    public let order: Int
    public let width: Int
    public let ref: OptionableProtocol.Type?
    public let nestedRef: RefViewEntityProtocol.Type?
    public let agregate: [Agregate]?
    public let keyPath: KeyPath<T, FieldProperty<T, V>>?
    
    public init(keyField: String,
         name n: String,
         fieldType f: FieldType,
         dataType t: DataType,
         label l: String,
         order o: Int,
         required r: Bool = true,
         ref rf: OptionableProtocol.Type? = nil,
         width w: Int = 200,
         disabled d: Bool = false,
         nestedRef nr: RefViewEntityProtocol.Type? = nil,
         agregate isa: [Agregate]? = nil,
         keyPath kp: KeyPath<T, FieldProperty<T, V>>? = nil
    ){
        self.keyField = keyField
        self.name = n
        self.fieldType = f
        self.dataType = t
        self.label = l
        self.required = r
        self.disabled = d
        self.width = w
        self.order = o
        self.ref = rf
        self.nestedRef = nr
        self.agregate = isa
        self.keyPath = kp
    }
    
    static func id() -> EntityProperty {
        self.init(keyField: "id", name: "id", fieldType: .hidden, dataType: .string, label: "id", order: 0)
    }
}
