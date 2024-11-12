// The Swift Programming Language
// https://docs.swift.org/swift-book

import Vapor

public extension Application {
    func loadViewEntityRoutes(routes: Vapor.RoutesBuilder) throws {
        try routes.register(collection: ViewEntityController())
    }
}

/// RouteCollection /entity/:registerName/...
/// view - getView
/// get - getEntity
/// save - saveEntity
/// recalculate - recalculateEntity
/// :id - deleteEntity
struct ViewEntityController: RouteCollection {
    
    public func boot(routes: Vapor.RoutesBuilder) throws {
        let entityGroup = routes.grouped("entity", ":registerName")
        entityGroup.get("view", use: getView)
        entityGroup.get("get", use: getEntity)
//        entityGroup.get("get", ":id", use: getView)
        entityGroup.post("save", use: saveEntity)
        entityGroup.post("recalculate", use: recalculateEntity)
        entityGroup.delete(":id", use: deleteEntity)
    }
    
    func test(request: Request) async throws -> String {
        return "ok"
    }
    
    func getView(request: Request) async throws -> ResponseEncoded {
        try await request.loadAll()

       
        if let entityID: String = request.query["withEntityID"] {
            return try await request.entityView.get(id: entityID)
        }
        if try request.entityView.fromFile {
            return try await request.entityView.get(id: nil)
        }

        return try request.entityView.responseEncoded()
    }
    
    func getEntity(request: Request) async throws -> GetResponseEncoded {
        try request.loadEntityType()
        return try await request.entityType.get(request: request)
    }
    
    func saveEntity(request: Request) async throws -> ResponseEncoded{
        try request.loadEntityType()
        return try await request.entityType.save(request: request)
    }
    
    func recalculateEntity(request: Request) async throws -> DTOResponseEncoded {
        try await request.loadAll()
        let (entity, view) = try await request.entityType.recalculate(request: request, view: request.entityView, triggerFieldName: request.query["triggerFieldName"])
        return DTOResponseEncoded(view: view, entity: entity)
    }
    
    func deleteEntity(request: Request) async throws -> DeleteResponseEncoded{
        try await request.loadAll()
        guard let id = request.parameters.get("id"),
              let uuid = UUID(uuidString: id)  else {
            throw Abort(.badRequest, reason: "No id.")
        }
        let force: Bool = request.query["force"] == "true"
        return try await request.entityType.delete(request: request, id: uuid, force: force)
    }
}


