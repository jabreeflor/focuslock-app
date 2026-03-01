import SwiftUI
import SwiftData

struct ScheduleListView: View {
    @Query(sort: \FocusSchedule.createdAt, order: .reverse) private var schedules: [FocusSchedule]
    @Environment(\.modelContext) private var modelContext
    @State private var showCreateSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 4) {
                        Text("Focus Schedules")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Manage your focus blocks")
                            .font(.system(size: 14))
                            .foregroundStyle(FLColor.cyan)
                    }
                    .padding(.top, 16)
                    
                    if schedules.isEmpty {
                        emptyState
                    } else {
                        ForEach(schedules) { schedule in
                            scheduleRow(schedule)
                        }
                    }
                    
                    // Add button
                    Button {
                        showCreateSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New Schedule")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(FLColor.cyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .glassCard()
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
            .focusLockBackground()
            .sheet(isPresented: $showCreateSheet) {
                ScheduleCreatorView()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(FLColor.lavender.opacity(0.5))
            Text("No schedules yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            Text("Create your first focus schedule to get started")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
    }
    
    private func scheduleRow(_ schedule: FocusSchedule) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(schedule.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    
                    DifficultyBadge(difficulty: schedule.difficulty, compact: true)
                }
                
                Text("\(schedule.daysFormatted) • \(schedule.startTimeFormatted) - \(schedule.endTimeFormatted)")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.6))
                
                Text("\(schedule.blockedAppNames.count) apps blocked")
                    .font(.system(size: 12))
                    .foregroundStyle(FLColor.cyan.opacity(0.8))
            }
            
            Spacer()
            
            if schedule.isActive {
                Circle()
                    .fill(FLColor.neonGreen)
                    .frame(width: 10, height: 10)
                    .shadow(color: FLColor.neonGreen.opacity(0.5), radius: 4)
            }
        }
        .padding(16)
        .glassCard()
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(schedule)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    ScheduleListView()
        .modelContainer(for: FocusSchedule.self)
}
