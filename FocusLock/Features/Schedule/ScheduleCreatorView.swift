import SwiftUI
import SwiftData

struct ScheduleCreatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = "Work Focus"
    @State private var selectedApps: Set<String> = ["Instagram", "TikTok", "Twitter", "Snapchat"]
    @State private var selectedDays: Set<DayOfWeek> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    @State private var startTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!
    @State private var endTime = Calendar.current.date(from: DateComponents(hour: 17, minute: 0))!
    @State private var difficulty: Difficulty = .medium
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                header
                
                // Schedule Name
                sectionCard("Schedule Name") {
                    TextField("", text: $name)
                        .font(.system(size: 17))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(FLColor.inputBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                        .tint(FLColor.cyan)
                }
                
                // Apps to Block
                sectionCard("Apps to Block") {
                    appGrid
                }
                
                // Days Active
                sectionCard("Days Active") {
                    dayPicker
                }
                
                // Time
                sectionCard("Time") {
                    timeRow
                }
                
                // Difficulty
                sectionCard("Difficulty Level") {
                    difficultyPicker
                }
                
                // Save
                Button {
                    saveSchedule()
                } label: {
                    Text("Save Schedule →")
                        .ctaButton()
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .focusLockBackground()
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 4) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            
            Text("Create Focus Schedule")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Lock in. Level up.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(FLColor.cyan)
        }
    }
    
    // MARK: - Section Card Helper
    
    private func sectionCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
            
            content()
        }
        .padding(16)
        .glassCard()
    }
    
    // MARK: - App Grid
    
    private var appGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 12) {
            ForEach(MockApp.all) { app in
                VStack(spacing: 6) {
                    MockAppIcon(
                        name: app.name,
                        color: app.color,
                        symbol: app.symbol,
                        size: 56,
                        isSelected: selectedApps.contains(app.name)
                    )
                    
                    Text(app.name)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .onTapGesture {
                    if selectedApps.contains(app.name) {
                        selectedApps.remove(app.name)
                    } else {
                        selectedApps.insert(app.name)
                    }
                }
            }
        }
    }
    
    // MARK: - Day Picker
    
    private var dayPicker: some View {
        HStack(spacing: 6) {
            ForEach(DayOfWeek.allCases) { day in
                Text(day.shortName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(selectedDays.contains(day) ? .white : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(selectedDays.contains(day) ? FLColor.purple : Color.clear)
                    )
                    .onTapGesture {
                        if selectedDays.contains(day) {
                            selectedDays.remove(day)
                        } else {
                            selectedDays.insert(day)
                        }
                    }
            }
        }
    }
    
    // MARK: - Time Row
    
    private var timeRow: some View {
        HStack(spacing: 12) {
            timeField("Start Time", time: $startTime)
            timeField("End Time", time: $endTime)
        }
    }
    
    private func timeField(_ label: String, time: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
            
            DatePicker("", selection: time, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .labelsHidden()
                .colorScheme(.dark)
                .tint(FLColor.cyan)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(FLColor.inputBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
        }
    }
    
    // MARK: - Difficulty Picker
    
    private var difficultyPicker: some View {
        HStack(spacing: 0) {
            ForEach(Difficulty.allCases, id: \.self) { level in
                Text(level.rawValue)
                    .font(.system(size: 14, weight: difficulty == level ? .bold : .regular))
                    .foregroundStyle(difficulty == level ? .white : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(difficulty == level ? Color.white.opacity(0.15) : .clear)
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            difficulty = level
                        }
                    }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(FLColor.inputBackground)
        )
    }
    
    // MARK: - Save
    
    private func saveSchedule() {
        let schedule = FocusSchedule(
            name: name,
            blockedAppNames: Array(selectedApps),
            daysOfWeek: selectedDays.map(\.rawValue),
            startHour: Calendar.current.component(.hour, from: startTime),
            startMinute: Calendar.current.component(.minute, from: startTime),
            endHour: Calendar.current.component(.hour, from: endTime),
            endMinute: Calendar.current.component(.minute, from: endTime),
            difficulty: difficulty
        )
        modelContext.insert(schedule)
        dismiss()
    }
}

#Preview {
    ScheduleCreatorView()
        .modelContainer(for: FocusSchedule.self)
}
