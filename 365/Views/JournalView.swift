import SwiftUI
import SwiftData

struct JournalView: View {
    let year: Int
    let dayOfYear: Int
    let isFuture: Bool

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""
    @State private var existingEntry: JournalEntry?
    @State private var saveTask: Task<Void, Never>?

    private var totalDays: Int {
        DateService.daysInYear(year)
    }

    private var dateHeader: String {
        guard let date = DateService.date(forYear: year, dayOfYear: dayOfYear) else {
            return "DAY \(dayOfYear)"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date).uppercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)

            if isFuture {
                futureMessage
            } else {
                journalEditor
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear(perform: loadEntry)
        .onDisappear(perform: saveEntry)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dateHeader)
                .font(Typography.largeTitle)
                .foregroundStyle(AppColors.textPrimary)
                .tracking(2)

            Text("Day \(dayOfYear) of \(totalDays)")
                .font(Typography.monoCaption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var futureMessage: some View {
        VStack {
            Spacer()
            Text("Not yet")
                .font(Typography.monoBody)
                .foregroundStyle(AppColors.textSecondary.opacity(0.6))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var journalEditor: some View {
        TextEditor(text: $text)
            .font(Typography.monoBody)
            .foregroundStyle(AppColors.textPrimary)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 20)
            .onChange(of: text) { _, _ in
                debouncedSave()
            }
    }

    private func loadEntry() {
        let descriptor = FetchDescriptor<JournalEntry>(
            predicate: JournalEntry.predicate(year: year, dayOfYear: dayOfYear)
        )
        if let entry = try? modelContext.fetch(descriptor).first {
            existingEntry = entry
            text = entry.text
        }
    }

    private func saveEntry() {
        saveTask?.cancel()

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            if let entry = existingEntry {
                modelContext.delete(entry)
                existingEntry = nil
            }
        } else {
            if let entry = existingEntry {
                entry.text = trimmed
                entry.updatedAt = .now
            } else {
                let newEntry = JournalEntry(year: year, dayOfYear: dayOfYear, text: trimmed)
                modelContext.insert(newEntry)
                existingEntry = newEntry
            }
        }

        try? modelContext.save()
    }

    private func debouncedSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                saveEntry()
            }
        }
    }
}

#Preview {
    NavigationStack {
        JournalView(year: 2026, dayOfYear: 11, isFuture: false)
    }
    .modelContainer(for: JournalEntry.self, inMemory: true)
}
