//
//  RefView.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

struct RefView<F: RefViewEntityModelProtocol>: RefViewModelProtocol {
    var refOptions: [String:RefOptionField] = [:]
    var refViews: [String: RefViewProtocol] = [:]
    static func load(refOptions ro: [String:RefOptionField], refViews rw: [String: RefViewProtocol]) -> RefViewProtocol {
        var refView = RefView()
        refView.refOptions = ro
        refView.refViews = rw
        return refView
    }
    init(){}
    
    init(from decoder: Decoder) throws {
        self.init()
    }
}