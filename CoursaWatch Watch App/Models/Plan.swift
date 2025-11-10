

//
//  Plan.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 26/10/25.
//

import Foundation

struct Plan: Hashable { 
    let id: UUID = UUID()
    let date: Date
    let title: String
    let targetDistance: String
    let intensity: String
    let recPace: String
}

