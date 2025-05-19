//
//  ParentProperty.swift
//  view-entity
//
//  Created by Georgie Ivanov on 12.11.24.
//

import Fluent
import Vapor
import TypesLib

public extension ParentProperty where To.IDValue == UUID {
    var idContainer: IDContainer {
        IDContainer(uuid: self.id)
    }
}
public extension OptionalParentProperty where To.IDValue == UUID {
    var idContainer: IDContainer? {
        IDContainer(id: self.id)
    }
}
