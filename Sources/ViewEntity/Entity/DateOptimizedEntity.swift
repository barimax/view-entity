//
//  DateOptimizedEntity.swift
//  view-entity
//
//  Created by Georgie Ivanov on 12.11.24.
//

import Fluent
import SwiftDate
import Foundation

public enum DateOptimizedTimeUnit {
    case year, month, day
    var timeUnit: Calendar.Component {
        switch(self){
        case .day:
            return .day
        case .month:
            return .month
        case .year:
            return .year
        }
    }
    func dateComponents(v: Int) -> DateComponents {
        switch(self){
        case .day:
            return v.days
        case .month:
            return v.months
        case .year:
            return v.years
        }
    }
}

public protocol DateOptimizedGetAllProtocol where Self: EntityModelProtocol {
    static var optimizedByKeyPath: KeyPath<Self, FieldProperty<Self, Date>> { get }
    static var optimizedPropertyName: String { get }
    static var timeUnit: DateOptimizedTimeUnit { get }
    static func optimizeByDate(query: QueryBuilder<Self>) -> QueryBuilder<Self>
    
}
public extension DateOptimizedGetAllProtocol {
    static var timeUnit: DateOptimizedTimeUnit { return .year }
    static func optimizeByDate(query: QueryBuilder<Self>) -> QueryBuilder<Self> {
        let date = (Date.now - Self.timeUnit.dateComponents(v: 1)).dateAtStartOf(Self.timeUnit.timeUnit)
        
        return query
            .filter(Self.optimizedByKeyPath > date)
            .sort(Self.optimizedByKeyPath, .descending)
    }
}
