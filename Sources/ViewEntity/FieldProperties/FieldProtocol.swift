//
//  FieldProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Foundation
import FluentKit

public enum DataType: String, Encodable, Sendable {
    case string, integer, float, bool, object, array, ref, datetime, uid, image, svg, iban
}
public enum FieldType: String, Encodable, Sendable {
    case text, number, select, selectMultiple, checkbox, radio, switchButton, textarea, date, time, dateTime, nestedForm, uid, hidden, nestedArray, rowDisplay, file, currency
}
public enum Agregate: String, Encodable, Sendable {
    case min, max, sum, average
}

// Codable keys
enum FieldCodingKeys: String, CodingKey {
    case fieldType, dataType, width, name, required, label, order, disabled, agregate
}

public protocol FieldProtocol: Encodable {
    var keyField: String { get }
    var name: String { get }
    var fieldType: FieldType { get set }
    var dataType: DataType { get }
    var label: String { get }
    var required: Bool { get set }
    var disabled: Bool { get set }
    var order: Int { get }
    var width: Int { get }
    var ref: OptionableProtocol.Type? { get }
    var nestedRef: RefViewEntityProtocol.Type? { get }
    var agregate: [Agregate]? { get }
}

public extension FieldProtocol {
    // Encodable conformance
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FieldCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(fieldType, forKey: .fieldType)
        try container.encode(dataType, forKey: .dataType)
        try container.encode(width, forKey: .width)
        try container.encode(required, forKey: .required)
        try container.encode(label, forKey: .label)
        try container.encode(order, forKey: .order)
        try container.encode(disabled, forKey: .disabled)
        try container.encode(agregate, forKey: .agregate)
    }
}
