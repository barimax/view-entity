//
//  EntityConfiguration.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Foundation

struct EntityConfiguration {
    var singleName: String
    var pluralName: String
    var fields: [FieldProtocol]
    var searchableDBFields: [String]
    var titleFieldName: String
}
