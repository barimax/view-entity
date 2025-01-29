//
//  DateOptimizedEntity.swift
//  view-entity
//
//  Created by Georgie Ivanov on 12.11.24.
//

import Fluent
import SwiftMoment
import Foundation

public protocol DateOptimizedGetAllProtocol where Self: EntityModelProtocol {
    static var optimizedByKeyPath: KeyPath<Self, FieldProperty<Self, Date>> { get }
    static var optimizedPropertyName: String { get }
    static var timeUnit: TimeUnit { get }
    static func optimizeByDate(query: QueryBuilder<Self>) -> QueryBuilder<Self>
    
}
public extension DateOptimizedGetAllProtocol {
    static var timeUnit: TimeUnit { return .Years }
    static func optimizeByDate(query: QueryBuilder<Self>) -> QueryBuilder<Self> {
        let date = moment().subtract(1, Self.timeUnit).startOf(.Years).date
        
        return query
            .filter(Self.optimizedByKeyPath > date)
            .sort(Self.optimizedByKeyPath, .descending)
    }
}
