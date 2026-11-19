import SwiftUI

@main
struct WatercanApp: App {
    @StateObject private var store = Store()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 900, minHeight: 620)
                .onAppear {
                    Reminder.schedule(hour: store.data.reminderHour,
                                      target: store.data.dailyTarget,
                                      symbol: store.data.currencySymbol)
                }
        }
    }
}
