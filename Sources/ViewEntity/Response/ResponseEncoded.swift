//
//  ResponseEncoded.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor

public struct ResponseEncoded: AsyncResponseEncodable, Encodable {
    public func encodeResponse(for request: Request) async throws -> Response {
        do {
            let data = try await request.appConfiguration.encoder.encode(self)
            return Response.init(status: .ok, headers: HTTPHeaders([("content-type","application/json")]), body: Response.Body.init(data: data))
        }catch{
            throw MyError.unconvirtible
        }
    }
    
    let view: ViewProtocol
    let entity: EntityCodable?
    let list: [EntityCodable]
    let lastLimit: Int
    var isLast: Bool {
        self.list.count < lastLimit
    }
    
    
    public init(view v: ViewProtocol, entity e: EntityCodable?, list l: [EntityCodable] = [], lastLimit la: Int = 30){
        self.view = v
        self.entity = e
        self.list = l
        self.lastLimit = la
    }
    
    // Conforms to Encodable
    enum CodingKeys: String, CodingKey {
        case entity, list, view, isLast
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(EncodableWrapper(self.entity), forKey: .entity)
        try container.encode(self.list.map { EncodableWrapper($0) }, forKey: .list)
        try container.encode(EncodableWrapper(self.view), forKey: .view)
        try container.encode(self.isLast, forKey: .isLast)
    }
}
