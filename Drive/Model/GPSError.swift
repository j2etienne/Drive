//
//  GPSError.swift
//  Drive
//
//  Created by Martin Normark on 07/09/16.
//  Copyright © 2016 Milkshake Software. All rights reserved.
//

import RealmSwift

class GPSError: Object {
    dynamic var date: NSDate = NSDate()
    dynamic var title: String = ""
    dynamic var message: String? = nil
}