import Foundation
import SwiftData

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: String {
        switch self {
        case .easy: return "00E676"
        case .medium: return "FBBF24"
        case .hard: return "F44336"
        }
    }
    
    var unlockDurationMinutes: Int {
        switch self {
        case .easy: return 5
        case .medium: return 10
        case .hard: return 15
        }
    }
}

enum DayOfWeek: Int, Codable, CaseIterable, Identifiable {
    case monday = 2, tuesday = 3, wednesday = 4, thursday = 5
    case friday = 6, saturday = 7, sunday = 1
    
    var id: Int { rawValue }
    
    var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
}

@Model
final class FocusSchedule {
    var id: UUID
    var name: String
    var blockedAppIdentifiers: [String]
    var blockedAppNames: [String]
    var daysOfWeek: [Int] // raw values of DayOfWeek
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var isRecurring: Bool
    var isActive: Bool
    var difficultyRaw: String
    var createdAt: Date
    
    var difficulty: Difficulty {
        get { Difficulty(rawValue: difficultyRaw) ?? .medium }
        set { difficultyRaw = newValue.rawValue }
    }
    
    var days: Set<DayOfWeek> {
        get { Set(daysOfWeek.compactMap { DayOfWeek(rawValue: $0) }) }
        set { daysOfWeek = newValue.map(\.rawValue) }
    }
    
    var startTimeFormatted: String {
        formatTime(hour: startHour, minute: startMinute)
    }
    
    var endTimeFormatted: String {
        formatTime(hour: endHour, minute: endMinute)
    }
    
    var daysFormatted: String {
        let sorted = days.sorted(by: { $0.rawValue < $1.rawValue })
        if sorted.count == 7 { return "Every day" }
        if sorted.count == 5 && !sorted.contains(.saturday) && !sorted.contains(.sunday) {
            return "Mon-Fri"
        }
        return sorted.map(\.shortName).joined(separator: ", ")
    }
    
    init(
        name: String = "",
        blockedAppIdentifiers: [String] = [],
        blockedAppNames: [String] = [],
        daysOfWeek: [Int] = [],
        startHour: Int = 9,
        startMinute: Int = 0,
        endHour: Int = 17,
        endMinute: Int = 0,
        isRecurring: Bool = true,
        isActive: Bool = true,
        difficulty: Difficulty = .medium
    ) {
        self.id = UUID()
        self.name = name
        self.blockedAppIdentifiers = blockedAppIdentifiers
        self.blockedAppNames = blockedAppNames
        self.daysOfWeek = daysOfWeek
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.isRecurring = isRecurring
        self.isActive = isActive
        self.difficultyRaw = difficulty.rawValue
        self.createdAt = Date()
    }
    
    private func formatTime(hour: Int, minute: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, period)
    }
}
