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
                .padding(.top, 32)
                .padding(.bottom, 16)

            Rectangle()
                .fill(AppColors.textSecondary.opacity(0.18))
                .frame(height: 1)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

            if isFuture {
                futureMessage
            } else {
                journalEditor
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: loadEntry)
        .onDisappear(perform: saveEntry)
    }

    private var header: some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .light, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)
                        .accessibilityLabel("Back")
                }
                .buttonStyle(.plain)

                Spacer()
            }

            Text(dateHeader)
                .font(Typography.largeTitle)
                .foregroundStyle(AppColors.textPrimary)
                .tracking(2)
        }
    }

    private var futureMessage: some View {
        VStack(alignment: .leading) {
            Text("This day hasn't happened yet! Come back when you've made some memories")
                .font(Typography.monoBody)
                .foregroundStyle(AppColors.textSecondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 26)
        .padding(.top, 8)
    }

    private var journalEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(Typography.monoBody)
                .foregroundStyle(AppColors.textPrimary)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 20)
                .onChange(of: text) { _, _ in
                    debouncedSave()
                }

            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Start typing here...")
                    .font(Typography.monoBody)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                    .padding(.horizontal, 26)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }
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
