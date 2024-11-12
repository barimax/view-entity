//
//  EntityTypes.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

/// Structure to decode get filter parameters
public struct FilterParam: Decodable {
    var name: [String]?
    var value: [String]?
}
