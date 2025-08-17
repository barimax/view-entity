//
//  EntityTypes.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

/// Structure to decode get filter parameters
public struct FilterParam: Decodable {
    var name: String?
    var value: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case value
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
    }
}
