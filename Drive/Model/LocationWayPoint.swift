//
//  LocationWayPoint.swift
//  Drive
//
//  Created by Martin Normark on 07/09/16.
//  Copyright © 2016 Milkshake Software. All rights reserved.
//

import RealmSwift

class LocationWayPoint: Object {
    dynamic var lat: Double = 0
    dynamic var lon: Double = 0
    dynamic var course: Double = 0
    dynamic var speed: Double = 0
    dynamic var date: NSDate = NSDate()
}