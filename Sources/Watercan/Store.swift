import Foundation
import SwiftUI

@MainActor
final class Store: ObservableObject {
    @Published var data: AppData { didSet { save() } }
    private let url: URL

    static let keyFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    init() {
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Watercan", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        url = dir.appendingPathComponent("data.json")
        if let d = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(AppData.self, from: d) {
            data = decoded
        } else {
            data = AppData()
        }
    }

    private func save() {
        if let d = try? JSONEncoder().encode(data) {
            try? d.write(to: url, options: .atomic)
        }
    }

    // MARK: Entries
    static func key(_ d: Date) -> String { keyFmt.string(from: d) }

    func entry(for date: Date) -> DayEntry {
        data.entries[Store.key(date)] ?? DayEntry(key: Store.key(date))
    }

    func update(_ date: Date, _ change: (inout DayEntry) -> Void) {
        var e = entry(for: date)
        change(&e)
        data.entries[e.key] = e
    }

    // MARK: Game logic
    func coins(for e: DayEntry) -> Int {
        var c = 0
        if e.watered { c += 10 }
        c += min(e.tries, 5)
        if data.dailyTarget > 0 && e.earned >= data.dailyTarget { c += 5 }
        return c
    }

    var totalCoinsEarned: Int { data.entries.values.reduce(0) { $0 + coins(for: $1) } }
    var coinsSpent: Int { data.redemptions.reduce(0) { $0 + $1.cost } }
    var balance: Int { totalCoinsEarned - coinsSpent }
    var level: Int { totalCoinsEarned / 100 + 1 }
    var levelProgress: Double { Double(totalCoinsEarned % 100) / 100 }
    var totalTries: Int { data.entries.values.reduce(0) { $0 + $1.tries } }
    var targetHits: Int {
        data.entries.values.filter { data.dailyTarget > 0 && $0.earned >= data.dailyTarget }.count
    }

    var streak: Int {
        let cal = Calendar.current
        var day = Date()
        if !entry(for: day).watered { day = cal.date(byAdding: .day, value: -1, to: day)! }
        var n = 0
        while entry(for: day).watered {
            n += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return n
    }

    var bestStreak: Int {
        let cal = Calendar.current
        let dates = data.entries.values.filter { $0.watered }
            .compactMap { Store.keyFmt.date(from: $0.key) }.sorted()
        var best = 0, run = 0
        var prev: Date?
        for d in dates {
            if let p = prev, cal.dateComponents([.day], from: p, to: d).day == 1 { run += 1 } else { run = 1 }
            best = max(best, run)
            prev = d
        }
        return best
    }

    var badges: [Badge] {
        let watered = data.entries.values.filter { $0.watered }.count
        return [
            Badge(id: "first", emoji: "💧", title: "First Drop", detail: "Water once", unlocked: watered >= 1),
            Badge(id: "s7", emoji: "🔥", title: "Week Warrior", detail: "7-day streak", unlocked: bestStreak >= 7),
            Badge(id: "s30", emoji: "🌸", title: "Full Bloom", detail: "30-day streak", unlocked: bestStreak >= 30),
            Badge(id: "t5", emoji: "🎯", title: "On Target", detail: "Hit daily minimum 5 times", unlocked: targetHits >= 5),
            Badge(id: "c100", emoji: "🪙", title: "Coin Collector", detail: "Earn 100 coins", unlocked: totalCoinsEarned >= 100),
            Badge(id: "l5", emoji: "⭐️", title: "Level 5", detail: "Reach level 5", unlocked: level >= 5),
            Badge(id: "dua", emoji: "🤲", title: "Dua Warrior", detail: "50 tries in total", unlocked: totalTries >= 50),
            Badge(id: "wish", emoji: "🎁", title: "Happy Daughter", detail: "Redeem a wish", unlocked: !data.redemptions.isEmpty)
        ]
    }

    func redeem(_ w: Wish) {
        guard balance >= w.cost else { return }
        data.redemptions.append(Redemption(wishName: w.name, cost: w.cost, date: Date()))
    }
}
