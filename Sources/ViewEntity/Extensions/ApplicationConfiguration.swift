//
//  Configuration.swift
//  view-entity
//
//  Created by Georgie Ivanov on 20.10.24.
//

import Foundation
import Vapor

extension Application {
    var appConfiguration: AppConfiguration {
        get {
            self.storage[AppConfigurationKey.self] ?? AppConfiguration(
                encoder: JSONEncoder(),
                decoder: JSONDecoder()
            )
        }
        set {
            self.storage[AppConfigurationKey.self] = newValue
        }
    }
}
struct AppConfigurationKey: StorageKey {
    typealias Value = AppConfiguration
}
struct AppConfiguration {
    var encoder: JSONEncoder = JSONEncoder()
    var decoder: JSONDecoder = JSONDecoder()
//    static var value: Config = Config()
//    static func load(_ app: Application) async throws {
//        Configuration.value = try await Config.getConfiguration(application: app)
//    }
}
