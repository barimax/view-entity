//
//  RefViewProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

public protocol RefViewProtocol: Codable, Sendable {
    var registerName: String { get }
    var fields: [FieldProtocol] { get set }
    var refOptions: [String:RefOptionField] { get set }
    var refViews: [String: RefViewProtocol] { get set }
    var isDocument: Bool { get }
    static func load(refOptions ro: [String:RefOptionField], refViews rw: [String: RefViewProtocol]) -> RefViewProtocol
}
private enum RefViewCodingKeys: String, CodingKey {
    case fields, refOptions, refViews, isDocument, registerName
}
public extension RefViewProtocol {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RefViewCodingKeys.self)
        try container.encode(fields.map { EncodableWrapper($0) }, forKey: .fields)
        try container.encode(refOptions, forKey: .refOptions)
        try container.encode(refViews.mapValues { EncodableWrapper($0)}, forKey: .refViews)
        try container.encode(isDocument, forKey: .isDocument)
        try container.encode(registerName, forKey: .registerName)
    }
}
