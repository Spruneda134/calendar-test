//
//  Event.swift
//  calendarTest
//
//  Created by David Medina on 9/29/24.
//

import Foundation

struct Event: Codable, Identifiable {
    var id: String
    var scheduleId: String
    var title: String
    var description: String
    var startTime: TimeInterval
    var endTime: TimeInterval
    var creationDate: TimeInterval
    
    init(id: String, scheduleId: String, title: String, description: String, startTime: Double, endTime: Double, creationDate: Double) {
        self.id = id
        self.scheduleId = scheduleId
        self.title = title
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.creationDate = creationDate
    }
}
