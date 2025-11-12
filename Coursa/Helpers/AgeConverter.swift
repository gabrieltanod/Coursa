//
//  AgeConverter.swift
//  Coursa
//
//  Created by Zikar Nurizky on 29/10/25.
//

import Foundation

func convertDateToAge(date: Date) -> Int {
    let calendar = Calendar.current
    let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
    return ageComponents.year ?? 0
}
