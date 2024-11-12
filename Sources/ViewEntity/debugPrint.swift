//
//  debugPrint.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

public func debugPrint(_ str: String, prefix: String = "[JORO]") {
#if DEBUG
    print("\(prefix) \(str)")
#endif
}
