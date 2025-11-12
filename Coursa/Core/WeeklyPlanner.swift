//
//  WeeklyPlanner.swift
//  Coursa
//
//  Created by Gabriel Tanod on 12/11/25.
//
//  Summary
//  -------
//  Splits a weekly Zone-2 minute target across the user's selected days,
//  producing simple Session blueprints (all Zone-2).
//
//  Responsibilities
//  ----------------
//  - Input: total minutes target and selected weekdays.
//  - Output: per-day durations for next week's sessions (Zone-2 only).
//  - Keep distribution even; small remainder goes to the longest day.
//
