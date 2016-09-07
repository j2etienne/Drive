//
//  LocationVisit.swift
//  Drive
//
//  Created by Martin Normark on 07/09/16.
//  Copyright © 2016 Milkshake Software. All rights reserved.
//

import RealmSwift

class LocationVisit: Object {
    dynamic var lat: Double = 0
    dynamic var lon: Double = 0
    dynamic var name: String = ""
    dynamic var date: NSDate = NSDate()
    dynamic var arrivalDate: NSDate? = nil
    dynamic var departureDate: NSDate? = nil
}