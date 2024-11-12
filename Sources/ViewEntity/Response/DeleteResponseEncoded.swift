//
//  DeleteResponseEncoded.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.

import Vapor

struct DeleteResponseEncoded: AsyncResponseEncodable, Encodable {
    public func encodeResponse(for request: Request) async throws -> Response {
        do {
            let data = try request.appConfiguration.encoder.encode(self)
            return Response.init(status: .ok, headers: HTTPHeaders([("content-type","application/json")]), body: Response.Body.init(data: data))
        }catch{
            throw MyError.unconvirtible
        }
    }
    
    let backRefsOptions: [BackRefOptions]
    var ok: Bool { backRefsOptions.isEmpty }
    
    init(backRefsOptions: [BackRefOptions]){
        self.backRefsOptions = backRefsOptions
    }
    
    // Conforms to Encodable
    enum CodingKeys: String, CodingKey {
        case backRefsOptions, ok
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(backRefsOptions, forKey: .backRefsOptions)
        try container.encode(ok, forKey: .ok)
    }
}
