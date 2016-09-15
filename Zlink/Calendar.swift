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
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let day = String(calendar.components(NSCalendarUnit.Day, fromDate: date).day)
        let month = String(calendar.components(NSCalendarUnit.Month, fromDate: date).month)
        let year = String(calendar.components(NSCalendarUnit.Year, fromDate: date).year)
        return month + "/" + day + "/" + year
    }
    
}