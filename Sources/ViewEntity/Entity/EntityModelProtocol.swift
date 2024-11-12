//
//  EntityModelProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import Fluent
import FluentKit
import FluentSQL
import MySQLKit
import SwiftDate

public protocol EntityModelProtocol: EntityProtocol, Equatable, Content, FluentKit.Fields, Model {
    /// ID container to hold and pass entity ID. Optional for non yet existing entity
    var idContainer: IDContainer? { get }
    
    
    static func count(query: QueryBuilder<Self>) async throws -> Int
    
    static func allQuery(query: QueryBuilder<Self>) -> QueryBuilder<Self>
    static func singleQuery(query: QueryBuilder<Self>) -> QueryBuilder<Self>
    /// Query builder used when filter datagrid list
    static func filterQuery(filter: [String: [UUID]], query: QueryBuilder<Self>) -> QueryBuilder<Self>
    
    static var parentFiledsKeys: [String: String] { get }
    /// Decodes request content to entity
    static func decodeRequest(request: Request) async throws -> Self
    /// Create transaction default to single create query
    static func createTransaction(createdEntity: Self, database: Database, request: Request) async throws -> EntityCodable
    /// Update transaction default to single update query
    static func updateTransaction(oldEntity: Self, newEntity: Self, database: Database, request: Request) async throws -> EntityCodable
    /// Default implementation of create query that does nothing
    static func create(newEntity: Self, database: Database, request: Request) async throws
    /// Default implementation of update query that does nothing
    static func update(oldEntity: Self, newEntity: Self, database: Database, request: Request) async throws
    
    
}

public extension EntityModelProtocol {
    /// Initialize ID container with current enttiy id
    var idContainer: IDContainer? { IDContainer(id: self.id) }
    /// Default implementation of query builders that returns pure unmodified query
    static func allQuery(query: QueryBuilder<Self>) -> QueryBuilder<Self> { query }
    static func singleQuery(query: QueryBuilder<Self>) -> QueryBuilder<Self> { query }
    static func filterQuery(filter: [String: [UUID]], query: QueryBuilder<Self>) -> QueryBuilder<Self> { query }
    /// Default init of no parent entity fields' keys
    static var parentFiledsKeys: [String: String] { [:] }
    /// Default implementation of request decoded content to entity
    static func decodeRequest(request: Request) async throws -> Self {
        try request.content.decode(Self.self)
    }
    /// Create transaction default to single create query
    static func createTransaction(createdEntity: Self, database: Database, request: Request) async throws -> EntityCodable {
        try await Self.create(newEntity: createdEntity, database: database, request: request)
        return createdEntity
    }
    /// Update transaction default to single update query
    static func updateTransaction(oldEntity: Self, newEntity: Self, database: Database, request: Request) async throws -> EntityCodable {
        try await Self.update(oldEntity: oldEntity, newEntity: newEntity, database: database, request: request)
        return newEntity
    }
    /// Default implementation of create query that does nothing
    static func create(newEntity: Self, database: Database, request: Request) async throws {
        return try await newEntity.create(on: database)
    }
    /// Default implementation of update query that does nothing
    static func update(oldEntity: Self, newEntity: Self, database: Database, request: Request) async throws {
        return try await newEntity.update(on: database)
    }
    
    /// Default implementation of update query that throws error when try to call on non recalculatable entity
    static func recalculate(request: Request, view: ViewProtocol?, triggerFieldName: String?) async throws -> (Encodable, ViewProtocol?) {
        throw Abort(.badRequest, reason: "Not recalculatable.")
    }
    
    /// Custom options default implementation returns nil
    static func customOptions(request: Request) async throws -> [String:[SelectOption]]? { nil }
}

public extension EntityModelProtocol {
    /// Returns sort direction from query. Used from get entity method for datagrid list
    static func getSortDirection(request: Request) -> DatabaseQuery.Sort.Direction {
        if let direction: String = request.query["sortDirection"] {
            if direction == "descending" {
                return DatabaseQuery.Sort.Direction.descending
            }else{
                return DatabaseQuery.Sort.Direction.ascending
            }
        }else{
            return DatabaseQuery.Sort.Direction.descending
        }
    }
    
    /// Returns query builder with applied sorting
    static func getSortQuery(query: QueryBuilder<Self>, sortBy: String?, sortDirection: DatabaseQuery.Sort.Direction) throws -> QueryBuilder<Self> {
        if sortBy != nil {
            return query.sort(DatabaseQuery.Field.path([FieldKey(stringLiteral: sortBy!)], schema: Self.schema), sortDirection)
        }else{
            return query.sort(DatabaseQuery.Field.path([FieldKey(stringLiteral: "created_at")], schema: Self.schema), sortDirection)
        }
    }
    
    /// Returns query builder with applied filter
     static func getFilterQuery(db: Database, filter: FilterParam) throws -> QueryBuilder<Self> {
         var tempQuery = self.allQuery(query: Self.query(on: db))
         if let filterName = filter.name,
            let filterValue = filter.value,
            filterName.count == filterValue.count {
             for (index, name) in filterName.enumerated(){
                 let value = filterValue[index]
                 let fieldNameList = name.components(separatedBy: ".")
                 let fieldName = fieldNameList.first!
                 print("[JORO] \(value)")
                 
                 if let entityProperty = Self.entityConfiguration.fields.first(where: { property in property.name == fieldName}){
                     if entityProperty.fieldType == .select || entityProperty.fieldType == .selectMultiple {
                         let valueReplaced = "[" + value.replacingOccurrences(of: ";", with: ",") + "]"
                         print("[JORO 1] \(valueReplaced)")
                         let decoded: [UUID] = try JSONDecoder().decode([UUID].self, from: valueReplaced.data(using: .utf8)!)
                         tempQuery = Self.filterQuery(filter: [name: decoded], query: tempQuery)
                             tempQuery.group(.or) { or in
                                 for uuid in decoded {
                                     or.filter(FieldKey(stringLiteral: entityProperty.keyField), .equal, uuid)
                                 }
                             }
                     }else if entityProperty.fieldType == .date || entityProperty.fieldType == .dateTime {
                         let valueReplaced = "[" + value.replacingOccurrences(of: ";", with: ",") + "]"
                         print("[JORO] \(valueReplaced)")
                         let decoded: [Int?] = try JSONDecoder().decode([Int?].self, from: valueReplaced.data(using: .utf8)!)
                         if decoded.count == 2,
                            let start = decoded[0],
                            let end = decoded[1] {
                             let region = Region(calendar: Calendars.gregorian, zone: Zones.europeSofia, locale: Locales.bulgarian)
                             let startDate = Date(milliseconds: start, region: region).dateAtStartOf(.day)
                             let endDate = Date(milliseconds: end).dateAtEndOf(.day)
                             print("[JORO] \(startDate)")
                             print("[JORO] \(endDate)")
                             tempQuery.filter(FieldKey(stringLiteral: entityProperty.keyField), .greaterThanOrEqual, startDate)
                             tempQuery.filter(FieldKey(stringLiteral: entityProperty.keyField), .lessThanOrEqual, endDate)
                         }
                         print(decoded)
                     }else if entityProperty.fieldType == .nestedArray || entityProperty.fieldType == .nestedForm,
                              let nestedFieldName = fieldNameList.count == 2 ? fieldNameList[1] : nil,
                              let nestedRef = entityProperty.nestedRef,
                              let nestedProperty: FieldProtocol = nestedRef.fields.first(where: { nestedProperty in nestedProperty.name == nestedFieldName}),
                              let nestedSchema = nestedRef._schema,
                              let parent = Self.parentFiledsKeys[entityProperty.name] {
                         if nestedProperty.fieldType == .select || nestedProperty.fieldType == .selectMultiple {
                             let valueReplaced = "[" + value.replacingOccurrences(of: ";", with: ",") + "]"
                             print("[JORO 2] \(valueReplaced)")
                             let decoded: [UUID] = try JSONDecoder().decode([UUID].self, from: valueReplaced.data(using: .utf8)!)
                             tempQuery.query.joins.append(.join(schema: nestedSchema, alias: nil, .inner, foreign: DatabaseQuery.Field.path([FieldKey(stringLiteral: parent)], schema: nestedSchema), local: DatabaseQuery.Field.path([FieldKey.id], schema: Self.schema)))
                             tempQuery.group(.or) { or in
                                 for uuid in decoded {
                                   or.filter(DatabaseQuery.Field.path([FieldKey(stringLiteral: nestedProperty.keyField)], schema: nestedSchema), .equal, DatabaseQuery.Value.bind(uuid))
                                 }
                             }
                         }
                         
                     }else{
                         tempQuery.filter(FieldKey(stringLiteral: entityProperty.keyField), .contains(inverse: false, .anywhere), value)
                     }
                 }
                 
             }
         }
         return tempQuery
     }
    
    static func getBackRefOptions(uuid: UUID, request: Request) async throws -> [BackRefOptions] {
        var result: [BackRefOptions] = []
        guard let view = try? request.entityView else {
            throw Abort(.internalServerError, reason: "View not loaded.")
        }
        for backRef in view.backRefs {
            if let optionable = backRef.entity as? OptionableEntityProtocol.Type {
                let options = try await optionable.backRefsOptions(fieldName: backRef.formField, id: uuid, database: request.companyDatabase())
                if !options.isEmpty {
                    result.append(BackRefOptions(backRef: backRef, options: options))
                }
            }
        }
        return result
    }
    
    /// Main function that returns all entities, sorted and filtered, for datagrid list
    static func get(request: Request) async throws -> GetResponseEncoded {
        let sortBy: String? = request.query["sortBy"]
        let sortDirection = Self.getSortDirection(request: request)
        let filter = try request.query.get(FilterParam.self, at: "filter")
        let tempQuery = try Self.getFilterQuery(db: request.companyDatabase(), filter: filter)
        let getAllQuery = try self.allQuery(query: Self.getSortQuery(query: tempQuery, sortBy: sortBy, sortDirection: sortDirection))
        let result = try await getAllQuery.all()
        return GetResponseEncoded(propertyName: sortBy ?? "", sortDirection: sortDirection.description, list: result, lastId: nil)
    }
    
    /// Default implementation of save function
    static func save(request: Request) async throws -> ResponseEncoded {
        do {
            let entity = try await self.decodeRequest(request: request)
            if let entityId = entity.id,
               let id = entityId as? Self.IDValue,
               let oldEntity = try await Self.find(id, on: request.companyDatabase()) {
                entity._$id.exists = true
                let codableEntity = try await request.companyDatabase().transaction { database -> EntityCodable in
                    return try await Self.updateTransaction(oldEntity: oldEntity, newEntity: entity, database: database, request: request)
                }
                let view = try await View<Self>(request: request)
                return ResponseEncoded(view: view, entity: codableEntity)
            }else{
                
             
                let codableEntity = try await request.companyDatabase().transaction { database -> EntityCodable in
                    return try await Self.createTransaction(createdEntity: entity, database: database, request: request)
                }
                let view: ViewProtocol = try request.isViewLoaded ? request.entityView : await View<Self>(request: request)
                return ResponseEncoded(view: view, entity: codableEntity)
            }
        }catch{
            throw error
        }
    }
    /// Delete entity from database. Use force: Bool = false for soft delete
    static func delete(request: Request, id: UUID, force: Bool) async throws -> DeleteResponseEncoded {
        
        let backRefOptions = try await Self.getBackRefOptions(uuid: id, request: request)
        if backRefOptions.isEmpty {
            do {
                try await Self.query(on: request.companyDatabase()).filter(FieldKey.id, .equal, id).delete(force: force)
            }catch{
                debugPrint(error)
                throw Abort(.custom(code: 591, reasonPhrase: error.localizedDescription), reason: "Записът не може да бъде изтрит.")
            }
        }
        return DeleteResponseEncoded(backRefsOptions: backRefOptions)
        
    }
    
    static func count(query: QueryBuilder<Self>) async throws -> Int { try await query.count() }
}

public extension EntityModelProtocol {
    /// Conforms to equatable by comparing entity id
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    static func loadView(_ r: Request, _ v: [String], full f: Bool = false) async throws -> ViewProtocol? {
        var view = try await View<Self>.load(req: r, views: v, full: f)
        print("[JORO] View loaded. Start count")
        view.rowsCount = try await Self.count(query: query(on: r.companyDatabase()))
        print("[JORO] Rows count \(view.rowsCount)")
        return view
    }
    
    static func pureView(_ r: Request) throws -> ViewProtocol {
        try View<Self>(request: r)
    }
    
    static func initView(
        request r: Request,
        loadedViewsRegisterNames views: [String] = [],
        transactionDB db: Database? = nil
    ) throws -> View<Self> {
        return try View<Self>.init(request: r, loadedViewsRegisterNames: views, transactionDB: db)
    }
}

public extension EntityModelProtocol where Self: LoadAllViewProtocol {
    static func view(_ r: Request, _ v: [String] = []) async throws -> ViewProtocol? {
        var view = try await View<Self>.load(req: r, views: v, full: true)
        view.rowsCount = try await Self.count(query: query(on: r.companyDatabase()))
        return view
    }
}

public extension EntityModelProtocol where Self: DateOptimizedGetAllProtocol, Self: LoadAllViewProtocol {
    static func view(_ r: Request, _ v: [String] = []) async throws -> ViewProtocol? {
        var view = try await View<Self>.load(req: r, views: v, full: true)
        view.rowsCount = try await Self.count(query: query(on: r.companyDatabase()))
        return view
    }
}
