//
//  FieldTypes.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor

public enum RefOptionFieldCodingKeys: String, CodingKey {
    case registerName, options, isButton, view
}
public struct RefOptionField: Encodable, Sendable {
    public let registerName: String
    public var options: [SelectOption]
    public var isButton: Bool
    let view: SimpleViewProtocol?
    public init(registerName: String, options: [SelectOption], isButton: Bool, view: SimpleViewProtocol?) {
        self.registerName = registerName
        self.options = options
        self.isButton = isButton
        self.view = view
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RefOptionFieldCodingKeys.self)
        try container.encode(registerName, forKey: .registerName)
        try container.encode(options, forKey: .options)
        try container.encode(isButton, forKey: .isButton)
        try container.encode(EncodableWrapper(view), forKey: .view)
    }
}
public struct BackRefs: Encodable, Sendable {
    var registerName: String = ""
    var formField: String = ""
    var singleName: String = ""
    var pluralName: String = ""
    var createNewByMultiple: Bool = false
    var createNewByMultipleFields: [String] = []
    let entity: EntityProtocol.Type
    
    init(entity e: EntityProtocol.Type) {
        self.entity = e
    }
    // Codable keys
    enum CodingKeys: String, CodingKey {
        case registerName, formField, names, singleName, pluralName, createNewByMultiple, createNewByMultipleFields
    }
    // Encodable conformance
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(registerName, forKey: .registerName)
        try container.encode(formField, forKey: .formField)
        try container.encode(singleName, forKey: .singleName)
        try container.encode(pluralName, forKey: .pluralName)
        try container.encode(createNewByMultiple, forKey: .createNewByMultiple)
        try container.encode(createNewByMultipleFields, forKey: .createNewByMultipleFields)
    }
    
}
public struct SelectOption: Codable, Equatable, Content, Sendable {
    public var value: String
    public var text: String
    public var addOn: String?
    public var enabled: Bool
    public init(value v: String, text t: String, enabled e: Bool = true){
        self.value = v
        self.text = t
        self.enabled = e
    }
}

public struct BackRefOptions: Encodable {
    let backRef: BackRefs
    let options: [SelectOption]
}
