import Foundation
import SwiftData

@Model
final class FocusSession {
    var id: UUID
    var scheduleId: UUID?
    var startTime: Date
    var endTime: Date
    var actualEndTime: Date?
    var completed: Bool
    var totalFocusSeconds: Int
    
    var duration: TimeInterval {
        (actualEndTime ?? endTime).timeIntervalSince(startTime)
    }
    
    var isActive: Bool {
        actualEndTime == nil && Date() < endTime
    }
    
    init(
        scheduleId: UUID? = nil,
        startTime: Date = .now,
        endTime: Date,
        completed: Bool = false
    ) {
        self.id = UUID()
        self.scheduleId = scheduleId
        self.startTime = startTime
        self.endTime = endTime
        self.actualEndTime = nil
        self.completed = completed
        self.totalFocusSeconds = 0
    }
}
