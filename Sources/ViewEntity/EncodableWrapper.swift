//
//  EncodableWrapper.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

public extension Encodable {
  fileprivate func encode(to container: inout SingleValueEncodingContainer) throws {
    try container.encode(self)
  }
}
public struct EncodableWrapper : Encodable {
    var value: Encodable?
    public init(_ value: Encodable?) {
        self.value = value
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let v = value {
            try v.encode(to: &container)
        }else{
            try container.encodeNil()
        }
        
    }
}
