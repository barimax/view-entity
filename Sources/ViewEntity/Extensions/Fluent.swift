//
//  File.swift
//
//
//  Created by Georgie Ivanov on 19.01.23.
//

import Foundation
import FluentKit

public protocol EntityPropertyProtocol where Model: FluentKit.Fields, Value: Codable {
    associatedtype Model
    associatedtype Value
    
    init(key: FieldKey)
}
extension FieldProperty: EntityPropertyProtocol  {}

public protocol PropertyProtocol where Value: EntityPropertyProtocol {
    associatedtype Value
    var entityProperty: FieldProtocol { get }
    var value: Value { get set }
}
@propertyWrapper
public final class EntityPropertyField<Value> where Value: EntityPropertyProtocol {
    public let entityProperty: FieldProtocol
    public var value: Value
    public var wrappedValue: Value {
        get {
            return value
        }
        set {
            self.value = newValue
        }
    }
    init(entityProperty: FieldProtocol) {
        self.entityProperty = entityProperty
        self.value = Value(key: FieldKey(stringLiteral: entityProperty.keyField))
    }
    public var projectedValue: EntityPropertyField<Value> {
        self
    }
}
extension EntityPropertyField: AnyProperty {
    public static var anyValueType: Any.Type {
        Value.self
    }
    
    public var anyValue: Any? {
        self.value
    }
}
extension EntityPropertyField: PropertyProtocol {}

extension Fields {
    public typealias EntityField<Value> = EntityFieldProperty<Self, Value> where Value: Codable
    typealias EntityPropertyWrapper<Value> = EntityPropertyField<Value> where Value: EntityPropertyProtocol
}





@propertyWrapper
public final class EntityFieldProperty<Model, Value>
where Model: FluentKit.Fields, Value: Codable, Value: Sendable {
    public let key: FieldKey
    let entityProperty: FieldProtocol
    var outputValue: Value?
    var inputValue: DatabaseQuery.Value?
    
    public var projectedValue: EntityFieldProperty<Model, Value> {
        self
    }

    public var wrappedValue: Value {
        get {
            guard let value = self.value else {
                fatalError("Cannot access field before it is initialized or fetched: \(self.key)")
            }
            return value
        }
        set {
            self.value = newValue
        }
    }

    public init(key: FieldKey, entityProperty: FieldProtocol) {
        self.key = key
        self.entityProperty = entityProperty
    }
}



extension EntityFieldProperty: Property {
    public var value: Value? {
        get {
            if let value = self.inputValue {
                switch value {
                case .bind(let bind):
                    return bind as? Value
                case .enumCase(let string):
                    return string as? Value
                case .default:
                    fatalError("Cannot access default field for '\(Model.self).\(key)' before it is initialized or fetched")
                default:
                    fatalError("Unexpected input value type for '\(Model.self).\(key)': \(value)")
                }
            } else if let value = self.outputValue {
                return value
            } else {
                return nil
            }
        }
        set {
            self.inputValue = newValue.map { .bind($0) }
        }
    }
}

// MARK: Queryable

extension EntityFieldProperty: AnyQueryableProperty {
    public var path: [FieldKey] {
        [self.key]
    }
}

extension EntityFieldProperty: QueryableProperty { }

// MARK: Query-addressable

extension EntityFieldProperty: AnyQueryAddressableProperty {
    public var anyQueryableProperty: AnyQueryableProperty { self }
    public var queryablePath: [FieldKey] { self.path }
}

extension EntityFieldProperty: QueryAddressableProperty {
    public var queryableProperty: EntityFieldProperty<Model, Value> { self }
}

// MARK: Database

extension EntityFieldProperty: AnyDatabaseProperty {
    public var keys: [FieldKey] {
        [self.key]
    }

    public func input(to input: DatabaseInput) {
        if let inputValue = self.inputValue {
            input.set(inputValue, at: self.key)
        }
    }

    public func output(from output: DatabaseOutput) throws {
        if output.contains(self.key) {
            self.inputValue = nil
            do {
                self.outputValue = try output.decode(self.key, as: Value.self)
            } catch {
                throw FluentError.invalidField(
                    name: self.key.description,
                    valueType: Value.self,
                    error: error
                )
            }
        }
    }
}

// MARK: Codable

extension EntityFieldProperty: AnyCodableProperty {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue)
    }

    public func decode(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let valueType = Value.self as? AnyOptionalType.Type {
            // Hacks for supporting optionals in @Field.
            // Using @OptionalField is preferred moving forward.
            if container.decodeNil() {
                self.wrappedValue = (valueType.nil as! Value)
            } else {
                self.wrappedValue = try container.decode(Value.self)
            }
        } else {
            self.wrappedValue = try container.decode(Value.self)
        }
    }
}
