//
//  LoadViewExtension.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Vapor
import Fluent

public extension ViewEntityProtocol {
    
    static func getRefOptionView(field: FieldProtocol, view: inout View<T>, isFullLoad: Bool) async throws -> SimpleViewProtocol? {
        if !view.loadedViewsRegisterNames.contains(field.ref!.registerName) || isFullLoad {
           return try await field.ref!.view((view.loadedViewsRegisterNames + [field.ref!.registerName]))
        }
        return nil
    }
    
    static func getRefView(view: inout View<T>, request: Request, nestedRef: RefViewEntityProtocol.Type, isFullLoad: Bool) async throws -> RefViewProtocol {
        let customOptions = try await nestedRef.customOptions(db: view.database)
        var refViewRefOptions: [String: RefOptionField] = [:]
        var refViewRefViews: [String: RefViewProtocol] = [:]
        for field in nestedRef.fields {
            if let ref = field.ref {
                let currentOptions = try await Self.currentOptions(
                    customOptions: customOptions,
                    field: field,
                    view: &view,
                    database: view.database
                )
                let refOptionView = try await Self.getRefOptionView(field: field, view: &view, isFullLoad: isFullLoad)
                let refOption = RefOptionField(registerName: ref.registerName, options: currentOptions, isButton: ref.isButton, view: refOptionView)
                refViewRefOptions[field.name] = refOption
            }
            if  let newNestedRef = field.nestedRef {
                let nestedRefView = try await Self.getRefView(view: &view, request: request, nestedRef: newNestedRef, isFullLoad: isFullLoad)
                refViewRefViews[field.name] = nestedRefView
            }
        }
        return nestedRef.refView(refOptions: refViewRefOptions, refViews: refViewRefViews)
    }
    
    static func load(req: Request, views: [String] = [], full isFullLoad: Bool = false) async throws -> ViewProtocol {
        print("[JORO] loadedViewsRegisterNames: \(views)")
        var view = try View<T>(request: req, loadedViewsRegisterNames: views)
        print("[JORO] load View for \(view.registerName)")
        let customOptions = try await T.customOptions(request: req)
        let refOptionsData = try await view.fields.filter{ $0.ref != nil}.asyncMap { field -> (String, RefOptionField) in
            let currentOptions = try await Self.currentOptions(
                customOptions: customOptions,
                field: field,
                view: &view,
                database: view.database
            )
            let refOptionView = try await Self.getRefOptionView(field: field, view: &view, isFullLoad: isFullLoad)
            let refOption = RefOptionField(registerName: field.ref!.registerName, options: currentOptions, isButton: field.ref!.isButton, view: refOptionView)
            return (field.name, refOption)
        }
        let refOptions: [String: RefOptionField] = Dictionary(uniqueKeysWithValues: refOptionsData)
        
        
        let refViewsData = try await view.fields.filter{ $0.nestedRef != nil}.asyncMap { field -> (String, RefViewProtocol) in
            let refView = try await Self.getRefView(view: &view, request: req, nestedRef: field.nestedRef!, isFullLoad: isFullLoad)
            return (field.name, refView)
        }
        print("[JORO] refViewsData: \(refViewsData.map { (k,v) in return k })")
        let refViews = Dictionary(uniqueKeysWithValues: refViewsData)
        
        let backRefs = try req.application.register.all
            .flatMap { entityType -> [BackRefs] in
                return try entityType.entityConfiguration.fields.filter { $0.ref != nil }.filter { $0.ref!.registerName == view.registerName }.map { field -> BackRefs in
                    var backRef = try BackRefs(entity: req.application.register.get(key: entityType.registerName)!)
                    backRef.registerName = entityType.registerName
                    backRef.singleName = entityType.entityConfiguration.singleName
                    backRef.pluralName = entityType.entityConfiguration.pluralName
                    backRef.formField = field.name
                    backRef.createNewByMultiple = field.dataType == .array && field.fieldType == .select ? true : false
                    return backRef
                }
        }
        view.refViews = refViews
        view.refOptions = refOptions
        view.backRefs = backRefs
        return view
    }
}
