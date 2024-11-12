//
//  MenuProtocol.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Foundation

public protocol MenuProtocol {
    static var registerName: String { get }
    static var entityConfiguration: EntityConfiguration { get set }
}
