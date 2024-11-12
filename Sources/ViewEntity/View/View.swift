//
//  View.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import Fluent

struct View<T: EntityModelProtocol>: ViewEntityProtocol {
    

    
    var rowsCount: Int = 0
    var forceServerLoad: Bool = false
    var refOptions: [String : RefOptionField] = [:]
    var backRefs: [BackRefs] = []
    var refViews: [String: RefViewProtocol] = [:]


    internal func responseEncoder(from: [EntityCodable]) -> ResponseEncoded {
        return ResponseEncoded(view: self, entity: nil, list: from)
    }
    internal func responseEncoder(from: [EntityCodable], lastLimit: Int) -> ResponseEncoded {
        return ResponseEncoded(view: self, entity: nil, list: from, lastLimit: lastLimit)
    }
    internal func responseEncoder(from: EntityCodable) -> ResponseEncoded {
        return ResponseEncoded(view: self, entity: from)
    }
    
    func responseEncoded() -> ResponseEncoded {
        return ResponseEncoded(view: self, entity: nil)
    }
    
    let request: Request
    let database: Database
    var loadedViewsRegisterNames: [String]
    
    init(request r: Request, loadedViewsRegisterNames views: [String] = [], transactionDB db: Database? = nil) async throws {
        self.request = r
        self.loadedViewsRegisterNames = views
        self.database = try db ?? r.companyDatabase()
    }
}
