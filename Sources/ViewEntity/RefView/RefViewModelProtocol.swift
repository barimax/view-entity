//
//  RefViewModelProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

public protocol RefViewModelProtocol: RefViewProtocol {
    associatedtype F: RefViewEntityModelProtocol
}

public extension RefViewModelProtocol {
    var isDocument: Bool { F.isDocument }
    var fields: [FieldProtocol] {
        get { F.fields }
        set(newValue) {
            F.fields = newValue
        }
    }
}
