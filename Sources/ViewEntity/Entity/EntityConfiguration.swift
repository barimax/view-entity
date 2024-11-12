//
//  EntityConfiguration.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Foundation

public struct EntityConfiguration {
    public var singleName: String
    public var pluralName: String
    public var fields: [FieldProtocol]
    public var searchableDBFields: [String]
    public var titleFieldName: String
    
    public init(singleName: String, pluralName: String, fields: [FieldProtocol], searchableDBFields: [String], titleFieldName: String) {
        self.singleName = singleName
        self.pluralName = pluralName
        self.fields = fields
        self.searchableDBFields = searchableDBFields
        self.titleFieldName = titleFieldName
    }
}
