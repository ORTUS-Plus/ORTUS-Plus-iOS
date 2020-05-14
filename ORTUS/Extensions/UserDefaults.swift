//
//  UserDefaults.swift
//  ORTUS
//
//  Created by Firdavs Khaydarov on 06/02/20.
//  Copyright © 2020 Firdavs. All rights reserved.
//

import Foundation

extension UserDefaults {
    struct Key<Value> {
        let name: String
        
        public init(_ name: String) {
            self.name = name
        }
    }
    
    func value<Value>(for key: Key<Value>) -> Value? {
        return object(forKey: key.name) as? Value
    }

    func set<Value>(_ value: Value, for key: Key<Value>) {
        set(value, forKey: key.name)
    }

    func removeValue<Value>(for key: Key<Value>) {
        removeObject(forKey: key.name)
    }
}

extension UserDefaults.Key where Value == Bool {
    static let firstInstall = Self("first_install")
    static let showEvents = Self("show_events")
}
