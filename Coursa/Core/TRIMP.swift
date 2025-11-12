//
//  TRIMP.swift
//  Coursa
//
//  Created by Gabriel Tanod on 12/11/25.
//
//  Summary
//  -------
//  Converts "how long" and "how hard" a session felt into a single
//  training load number. For v1 we keep it minimal and hardcode HRmax.
//
//  Responsibilities
//  ----------------
//  - Compute TRIMP per session from duration + avgHR (or a simple proxy).
//  - Sum TRIMP across a week.
//  - Use a hardcoded HRmax and Zone-2 bounds for now (no user profile yet).
//
