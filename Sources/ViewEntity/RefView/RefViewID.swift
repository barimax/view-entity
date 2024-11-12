//
//  RefViewID.swift
//  view-entity
//
//  Created by Georgie Ivanov on 12.11.24.
//
import Foundation

@propertyWrapper public class RefViewID: Codable {
    public var wrappedValue: UUID?
    public init(wrappedValue: UUID?){
        self.wrappedValue = wrappedValue ?? UUID()
    }
    
    required public init(from decoder: Decoder) throws {
        print("[JORO] Decode here")
        do{
            let singleContainer = try decoder.singleValueContainer()
            wrappedValue = (try? singleContainer.decode(UUID.self)) ?? UUID()
        }catch{
            print("[JORO] Error here")
            print(error)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
    
}
