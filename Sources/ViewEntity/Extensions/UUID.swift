//
//  UUID.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//
import Foundation

public extension UUID {
    func hexEncodedString(uppercase: Bool = false) -> String {
        func asUInt8Array() -> [UInt8]{
            let (u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16) = self.uuid
            return [u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16]
        }
       
        return asUInt8Array().map {
                if $0 < 16 {
                    return "0" + String($0, radix: 16, uppercase: uppercase)
                } else {
                    return String($0, radix: 16, uppercase: uppercase)
                }
        }.joined()
    }
}
