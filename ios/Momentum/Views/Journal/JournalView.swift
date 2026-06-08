import SwiftUI

struct JournalView: View {
    @State private var entries: [JournalEntry] = []
    @State private var newEntryText = ""
    @State private var moodScore: Int = 5
    @State private var showNewEntry = false
    private let defaults = UserDefaults.standard
    private let key = "momentum_journal_entries"
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Journal")
                                .font(.momentumLargeTitle)
                                .foregroundColor(.white)
                            Text("\(entries.count) entries • Track your journey")
                                .font(.momentumSubheadline)
                                .foregroundColor(.momentumTextSecondary)
                        }
                        Spacer()
                        Button(action: { showNewEntry.toggle() }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.momentumTeal)
                        }
                    }
                    .padding(.horizontal)
                    
                    if entries.isEmpty {
                        VStack(spacing: 16) {
                            Spacer().frame(height: 60)
                            Image(systemName: "book.pencil")
                                .font(.system(size: 60))
                                .foregroundColor(.momentumTextTertiary)
                            Text("No journal entries yet")
                                .font(.momentumHeadline)
                                .foregroundColor(.momentumTextSecondary)
                            Text("Start writing to track your thoughts and mood")
                                .font(.momentumSubheadline)
                                .foregroundColor(.momentumTextTertiary)
                            Button(action: { showNewEntry.toggle() }) {
                                Text("Write First Entry")
                                    .font(.momentumCallout)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.momentumTeal)
                                    .cornerRadius(12)
                            }
                        }
                    } else {
                        ForEach(entries.sorted(by: { $0.date > $1.date })) { entry in
                            JournalEntryCard(entry: entry)
                                .padding(.horizontal)
                        }
                    }
                    
                    Spacer().frame(height: 80)
                }
                .padding(.top)
            }
        }
        .sheet(isPresented: $showNewEntry) {
            NewJournalEntryView { entry in
                entries.append(entry)
                saveEntries()
            }
        }
        .onAppear {
            loadEntries()
        }
    }
    
    private func loadEntries() {
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            entries = decoded
        }
    }
    
    private func saveEntries() {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: key)
        }
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    
    var body: some View {
        MomentumCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(formattedDate(entry.date))
                        .font(.momentumCaption)
                        .foregroundColor(.momentumTextTertiary)
                    Spacer()
                    MoodIndicator(score: entry.moodScore)
                }
                Text(entry.text)
                    .font(.momentumBody)
                    .foregroundColor(.white)
                    .lineSpacing(4)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • h:mm a"
        return formatter.string(from: date)
    }
}

struct NewJournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var text = ""
    @State private var moodScore = 5
    let onSave: (JournalEntry) -> Void
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("New Entry")
                        .font(.momentumTitle2)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.momentumTextSecondary)
                    }
                }
                .padding(.horizontal)
                
                // Mood picker
                VStack(spacing: 8) {
                    Text("How are you feeling?")
                        .font(.momentumHeadline)
                        .foregroundColor(.white)
                    HStack(spacing: 12) {
                        ForEach(1...10, id: \.self) { score in
                            Circle()
                                .fill(score <= moodScore ? moodColor(score) : Color.momentumGlass)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Text("\(score)")
                                        .font(.momentumCaption)
                                        .foregroundColor(score <= moodScore ? .white : .momentumTextTertiary)
                                )
                                .onTapGesture { moodScore = score }
                        }
                    }
                    Text(moodLabel)
                        .font(.momentumCaption)
                        .foregroundColor(.momentumTextSecondary)
                }
                .padding(.horizontal)
                
                // Text editor
                TextEditor(text: $text)
                    .font(.momentumBody)
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .padding()
                    .background(Color.momentumGlass)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                // Save button
                Button(action: save) {
                    Text("Save Entry")
                        .font(.momentumHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(text.trimmingCharacters(in: .whitespaces).isEmpty ? Color.momentumTextTertiary : Color.momentumTeal)
                        .cornerRadius(14)
                }
                .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
        }
    }
    
    private var moodLabel: String {
        switch moodScore {
        case 1...3: return "Low"
        case 4...5: return "Okay"
        case 6...7: return "Good"
        case 8...9: return "Great"
        case 10: return "Excellent"
        default: return ""
        }
    }
    
    private func moodColor(_ score: Int) -> Color {
        switch score {
        case 1...3: return .momentumStress
        case 4...5: return .momentumEnergy
        case 6...7: return .momentumTeal
        case 8...10: return .momentumRecovery
        default: return .momentumTextSecondary
        }
    }
    
    private func save() {
        let entry = JournalEntry(
            date: Date(),
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            moodScore: moodScore
        )
        onSave(entry)
        dismiss()
    }
}

struct MoodIndicator: View {
    let score: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { i in
                Circle()
                    .fill(i * 2 <= score ? Color.momentumTeal : Color.momentumGlass)
                    .frame(width: 6, height: 6)
            }
        }
    }
}
