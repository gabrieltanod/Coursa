//
//  FindNextWeekMonday.swift
//  Coursa
//
//  Created by Zikar Nurizky on 04/11/25.
//

import Foundation

func FindNextWeekMonday() -> Date {
    let calendar = Calendar.current
    let today = Date()
    let nextMonday = calendar.nextDate(
        after: today,
        matching: DateComponents(weekday: 2), // Monday is 2 in the Gregorian calendar (Sunday=1)
        matchingPolicy: .nextTime
    )!
    
    return nextMonday
}
