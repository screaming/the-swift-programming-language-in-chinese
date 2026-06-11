import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \RollRecord.timestamp, order: .reverse) private var records: [RollRecord]

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    ContentUnavailableView(
                        "暂无历史",
                        systemImage: "clock",
                        description: Text("每次掷骰都会自动记录在这里。")
                    )
                } else {
                    List {
                        ForEach(records) { record in
                            NavigationLink {
                                HistoryDetailView(record: record)
                            } label: {
                                row(for: record)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("历史")
            .toolbar {
                if !records.isEmpty {
                    Button(role: .destructive, action: clearAll) {
                        Label("清空", systemImage: "trash")
                    }
                }
            }
        }
    }

    private func row(for record: RollRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.summary).font(.headline)
                Text(record.timestamp, format: .dateTime.month().day().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(record.total)")
                .font(.title2.bold())
                .monospacedDigit()
                .foregroundStyle(.tint)
        }
    }

    private func delete(_ offsets: IndexSet) {
        for index in offsets {
            context.delete(records[index])
        }
    }

    private func clearAll() {
        for record in records {
            context.delete(record)
        }
    }
}

struct HistoryDetailView: View {
    let record: RollRecord

    var body: some View {
        List {
            Section("结果") {
                LabeledContent("组合", value: record.summary)
                LabeledContent("总和", value: "\(record.total)")
                if record.modifier != 0 {
                    LabeledContent(
                        "修正值",
                        value: record.modifier > 0 ? "+\(record.modifier)" : "\(record.modifier)"
                    )
                }
                LabeledContent("时间") {
                    Text(record.timestamp, format: .dateTime.year().month().day().hour().minute())
                }
            }
            Section("各骰点数") {
                DieResultView(rolls: record.rolls)
                    .padding(.vertical, 4)
            }
        }
        .navigationTitle("详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
