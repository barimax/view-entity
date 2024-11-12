//
//  GetResponseEncoded.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor

struct GetResponseEncoded: AsyncResponseEncodable, Encodable {
    public func encodeResponse(for request: Request) async throws -> Response {
        do {
            let data = try request.appConfiguration.encoder.encode(self)
            return Response.init(status: .ok, headers: HTTPHeaders([("content-type","application/json")]), body: Response.Body.init(data: data))
        }catch{
            throw MyError.unconvirtible
        }
    }
    let list: [EntityCodable]
    let lastId: UUID?
    let propertyName: String
    let sortDirection: String
    var isLast: Bool {
        lastId == nil || list.count < 300
    }
    init(propertyName s: String = "", sortDirection sd: String = "", list l: [EntityCodable] = [], lastId id: UUID?){
        self.list = l
        self.lastId = id
        self.propertyName = s
        self.sortDirection = sd
    }
    // Conforms to Encodable
    enum CodingKeys: String, CodingKey {
        case list, lastId, isLast, propertyName, sortDirection
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.list.map { EncodableWrapper($0) }, forKey: .list)
        try container.encode(self.isLast, forKey: .isLast)
        try container.encode(self.lastId, forKey: .lastId)
        try container.encode(self.propertyName, forKey: .propertyName)
        try container.encode(self.sortDirection, forKey: .sortDirection)
    }
}
