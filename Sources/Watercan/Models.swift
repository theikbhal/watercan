import Foundation

struct DayEntry: Codable, Identifiable, Hashable {
    var id: String { key }
    var key: String
    var watered = false
    var earned: Double = 0
    var tries = 0
    var notes = ""
    var project = ""
    var event = ""
}

struct Wish: Codable, Identifiable, Hashable {
    var id = UUID()
    var emoji: String
    var name: String
    var cost: Int

    static let defaultWishes: [Wish] = [
        Wish(emoji: "🍪", name: "Biscuit (morning)", cost: 20),
        Wish(emoji: "🍪", name: "Biscuit (afternoon)", cost: 20),
        Wish(emoji: "🥨", name: "Snack", cost: 30),
        Wish(emoji: "🍞", name: "Cream bun", cost: 40)
    ]
}

struct Redemption: Codable, Identifiable, Hashable {
    var id = UUID()
    var wishName: String
    var cost: Int
    var date: Date
}

struct AppData: Codable {
    var entries: [String: DayEntry] = [:]
    var wishes: [Wish] = Wish.defaultWishes
    var redemptions: [Redemption] = []
    var dailyTarget: Double = 500
    var reminderHour: Int = 20
    var currencySymbol: String = "₹"
}

struct Badge: Identifiable {
    let id: String
    let emoji: String
    let title: String
    let detail: String
    let unlocked: Bool
}
