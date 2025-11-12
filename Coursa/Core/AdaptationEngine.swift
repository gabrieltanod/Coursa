//
//  AdaptationEngine.swift
//  Coursa
//
//  Created by Gabriel Tanod on 12/11/25.
//
//  Summary
//  -------
//  Decides next week's total work based on last week's load,
//  capped at +10% growth.
//
//  Responsibilities
//  ----------------
//  - Input: last week's TRIMP or total Zone-2 minutes.
//  - Output: next week's Zone-2 minute target.
//  - Apply growth cap (+10%) and 16-week ceiling.
//  - Keep logic simple and deterministic for v1.
//
