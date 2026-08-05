//
//  RecalculateResponseEncoded.swift
//  view-entity
//
//  Created by Georgie Ivanov on 5.08.26.
//

import Vapor

public struct RecalculateResponseEncoded: AsyncResponseEncodable, Encodable {
    public func encodeResponse(for request: Request) async throws -> Response {
        do {
            
            let data = try await request.appConfiguration.encoder.encode(self)
            return Response.init(status: .ok, headers: HTTPHeaders([("content-type","application/json")]), body: Response.Body.init(data: data))
        }catch{
            throw MyError.unconvirtible
        }
        
    }
    
    let entity: Encodable?
    let fields: [any FieldProtocol]?
    let refOptions: [String: RefOptionField]?
    
    public init(entity: Encodable?, fields: [any FieldProtocol]?, refOptions: [String : RefOptionField]?) {
        self.entity = entity
        self.fields = fields
        self.refOptions = refOptions
    }
    
    // Conforms to Encodable
    enum CodingKeys: String, CodingKey {
        case entity, fields, refOptions
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(EncodableWrapper(self.entity), forKey: .entity)
        try container.encode(fields?.map {EncodableWrapper($0)}, forKey: .fields)
        try container.encode(refOptions, forKey: .refOptions)
    }
}
