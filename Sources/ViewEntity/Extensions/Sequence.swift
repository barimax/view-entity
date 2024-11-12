//
//  Sequence.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
    func asyncForEach(
            _ operation: (Element) async throws -> Void
        ) async rethrows {
            for element in self {
                try await operation(element)
            }
        }
}
