//
//  RefView.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

public struct RefView<F: RefViewEntityModelProtocol>: RefViewModelProtocol {
    public var refOptions: [String:RefOptionField] = [:]
    public var refViews: [String: RefViewProtocol] = [:]
    public static func load(refOptions ro: [String:RefOptionField], refViews rw: [String: RefViewProtocol]) -> RefViewProtocol {
        var refView = RefView()
        refView.refOptions = ro
        refView.refViews = rw
        return refView
    }
    public init(){}
    
    public init(from decoder: Decoder) throws {
        self.init()
    }
}
