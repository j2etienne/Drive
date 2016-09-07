//
//  DataStore.swift
//  Drive
//
//  Created by Martin Normark on 07/09/16.
//  Copyright © 2016 Milkshake Software. All rights reserved.
//

import RealmSwift

class DataStore: NSObject {
    class var sharedInstance: Realm {

        struct Singleton {
            static let instance = try! Realm()
        }

        return Singleton.instance
    }
}