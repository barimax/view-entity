//
//  SimpleView.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

public struct SimpleView<T: EntityModelProtocol>: SimpleViewEntityProtocol {
    public var loadedViewsRegisterNames: [String]
    
    public init(loadedViewsRegisterNames: [String]) {
        self.loadedViewsRegisterNames = loadedViewsRegisterNames
    }
}
