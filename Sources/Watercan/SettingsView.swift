import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store

    private func reschedule() {
        Reminder.schedule(hour: store.data.reminderHour,
                          target: store.data.dailyTarget,
                          symbol: store.data.currencySymbol)
    }

    var body: some View {
        Form {
            TextField("Daily minimum to earn", value: $store.data.dailyTarget, format: .number)
            TextField("Currency symbol", text: $store.data.currencySymbol)
            Stepper("Reminder at \(store.data.reminderHour):00", value: $store.data.reminderHour, in: 0...23)
            Button("Update reminder now") { reschedule() }
        }
        .formStyle(.grouped)
        .onChange(of: store.data.reminderHour) { _, _ in reschedule() }
        .onChange(of: store.data.dailyTarget) { _, _ in reschedule() }
    }
}
