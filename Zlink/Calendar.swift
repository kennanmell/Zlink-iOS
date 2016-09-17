//
//  Calendar.swift
//  Zlink
//
//  Created by Kennan Mell on 3/22/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import Foundation

/** `Calendar` is a collection of static functions relating to dates/calendars. */
struct Calendar {
    
    // MARK: Functions
    
    /**
     Returns the current date as a `String` in the form "mm/dd/yyyy".
     - returns: The current date as a String.
     */
    static func getCurrentDate() -> String {
        let date = Date()
        let calendar = Foundation.Calendar.current
        let day = String(describing: (calendar as NSCalendar).components(NSCalendar.Unit.day, from: date).day)
        let month = String(describing: (calendar as NSCalendar).components(NSCalendar.Unit.month, from: date).month)
        let year = String(describing: (calendar as NSCalendar).components(NSCalendar.Unit.year, from: date).year)
        return month + "/" + day + "/" + year
    }
    
}
