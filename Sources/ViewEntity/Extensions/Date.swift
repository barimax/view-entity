//
//  Date.swift
//  view-entity
//
//  Created by Georgie Ivanov on 12.11.24.
//

import Foundation

extension Date {
    var calendar: Calendar {
        return Calendar(identifier: .iso8601)
    }
    var weekInterval: DateInterval {
        let weekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let startOfWeek = calendar.date(from: weekComponents)!
        let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
        return DateInterval(start: startOfWeek, end: endOfWeek)
    }
    
}
