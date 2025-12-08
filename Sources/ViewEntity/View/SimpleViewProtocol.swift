//
//  SimpleViewProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Foundation

public protocol SimpleViewProtocol: Encodable, Sendable {
    var fields: [FieldProtocol] { get }
    var registerName: String { get }
    var singleName: String { get }
    var pluralName: String { get }
    var titleFieldName: String { get }
    var loadedViewsRegisterNames: [String] { get set }
    var isDocument: Bool { get }
}

public extension SimpleViewProtocol {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ViewCodingKeys.self)
        try container.encode(singleName, forKey: .singleName)
        try container.encode(pluralName, forKey: .pluralName)
        try container.encode(fields.map { EncodableWrapper($0) }, forKey: .fields)
        try container.encode(registerName, forKey: .registerName)
        try container.encode(titleFieldName, forKey: .titleFieldName)
        try container.encode(isDocument, forKey: .isDocument)
    }
}
