//
//  View.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import Fluent

public struct View<T: EntityModelProtocol>: ViewEntityProtocol {
    

    
    public var rowsCount: Int = 0
    public var forceServerLoad: Bool = false
    public var refOptions: [String : RefOptionField] = [:]
    public var backRefs: [BackRefs] = []
    public var refViews: [String: RefViewProtocol] = [:]


    public func responseEncoder(from: [EntityCodable]) -> ResponseEncoded {
        return ResponseEncoded(view: self, entity: nil, list: from)
    }
    public func responseEncoder(from: [EntityCodable], lastLimit: Int) -> ResponseEncoded {
        return ResponseEncoded(view: self, entity: nil, list: from, lastLimit: lastLimit)
    }
    public func responseEncoder(from: EntityCodable) -> ResponseEncoded {
        return ResponseEncoded(view: self, entity: from)
    }
    
    public func responseEncoded() -> ResponseEncoded {
        return ResponseEncoded(view: self, entity: nil)
    }
    
    public let request: Request
    public let database: Database
    public var loadedViewsRegisterNames: [String]
    
    public init(request r: Request, loadedViewsRegisterNames views: [String] = [], transactionDB db: Database? = nil) async throws {
        self.request = r
        self.loadedViewsRegisterNames = views
        self.database = try db ?? r.companyDatabase()
    }
}
