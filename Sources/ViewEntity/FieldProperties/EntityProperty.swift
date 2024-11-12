//
//  EntityProperty.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//
import Fluent

struct EntityProperty<T, V>: FieldProtocol where T: Model, V: Codable, V: Sendable {
    let keyField: String
    let name: String
    var fieldType: FieldType
    let dataType: DataType
    let label: String
    var required: Bool
    var disabled: Bool
    let order: Int
    let width: Int
    let ref: OptionableProtocol.Type?
    let nestedRef: RefViewEntityProtocol.Type?
    let agregate: [Agregate]?
    let keyPath: KeyPath<T, FieldProperty<T, V>>?
    
    init(keyField: String,
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
