//
//  GoalActivity.swift
//  ZakFit
//
//  Created by Klesya on 05/01/2025.
//

import Foundation

struct GoalActivity: Codable, Identifiable, @unchecked Sendable {

    var id: UUID
    var frequency: Int?
    var caloriesGoal: Double?
    var durationGoal: Double?
    var typeActivityId: UUID
    var userId: UUID

    init() {
        self.id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        self.frequency = nil
        self.caloriesGoal = nil
        self.durationGoal = nil
        self.typeActivityId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        self.userId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    }

    init(id: UUID, frequency: Int?, caloriesGoal: Double?, durationGoal: Double?, typeActivityId: UUID, userId: UUID) {
        self.id = id
        self.frequency = frequency
        self.caloriesGoal = caloriesGoal
        self.durationGoal = durationGoal
        self.typeActivityId = typeActivityId
        self.userId = userId
    }
}
