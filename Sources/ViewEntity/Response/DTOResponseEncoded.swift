//
//  DTOResponseEncoded.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor

struct DTOResponseEncoded: AsyncResponseEncodable, Encodable {
    func encodeResponse(for request: Request) async throws -> Response {
        do {
            
            let data = try request.appConfiguration.encoder.encode(self)
            return Response.init(status: .ok, headers: HTTPHeaders([("content-type","application/json")]), body: Response.Body.init(data: data))
        }catch{
            throw MyError.unconvirtible
        }
        
    }
    
    let view: ViewProtocol?
    let entity: Encodable?
    let isLast: Bool = false
    
    init(view v: ViewProtocol?, entity e: Encodable?){
        self.view = v
        self.entity = e
    }
    
    // Conforms to Encodable
    enum CodingKeys: String, CodingKey {
        case entity, view, isLast
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(EncodableWrapper(self.entity), forKey: .entity)
        try container.encode(EncodableWrapper(self.view), forKey: .view)
        try container.encode(EncodableWrapper(self.isLast), forKey: .isLast)
    }
}
