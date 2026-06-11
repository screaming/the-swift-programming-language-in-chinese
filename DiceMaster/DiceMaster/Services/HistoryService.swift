import Foundation
import SwiftData

/// 历史记录的写入与裁剪。
enum HistoryService {
    /// 记录一次掷骰，并按上限裁剪最旧的记录。
    static func record(_ outcome: RollOutcome, in context: ModelContext, limit: Int) {
        context.insert(RollRecord(outcome: outcome))
        prune(in: context, limit: limit)
    }

    /// 仅保留最近 `limit` 条记录。
    static func prune(in context: ModelContext, limit: Int) {
        let descriptor = FetchDescriptor<RollRecord>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        guard let all = try? context.fetch(descriptor), all.count > limit else { return }
        for record in all[limit...] {
            context.delete(record)
        }
    }
}
