import Foundation
import UserNotifications

enum Reminder {
    static func schedule(hour: Int, target: Double, symbol: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        center.removePendingNotificationRequests(withIdentifiers: ["daily"])

        let content = UNMutableNotificationContent()
        content.title = "Water your plant 🌱"
        content.body = "Please earn at least \(symbol)\(Int(target)) today. Make your dua, try your best!"

        var comps = DateComponents()
        comps.hour = hour
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        center.add(UNNotificationRequest(identifier: "daily", content: content, trigger: trigger))
    }
}
