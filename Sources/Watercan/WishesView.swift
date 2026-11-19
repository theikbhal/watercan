import SwiftUI

struct WishesView: View {
    @EnvironmentObject var store: Store
    @State private var emoji = "🍪"
    @State private var name = ""
    @State private var cost = 20

    var body: some View {
        List {
            Section("Balance") {
                Text("🪙 \(store.balance) coins").font(.title2.bold())
            }
            Section("Wishes") {
                ForEach(store.data.wishes) { w in
                    HStack {
                        Text(w.emoji).font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text(w.name).font(.headline)
                            Text("🪙 \(w.cost)").foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Redeem") { store.redeem(w) }
                            .disabled(store.balance < w.cost)
                    }
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            store.data.wishes.removeAll { $0.id == w.id }
                        }
                    }
                }
            }
            Section("Add a wish") {
                HStack {
                    TextField("Emoji", text: $emoji).frame(width: 50)
                    TextField("Name", text: $name)
                    Stepper("🪙 \(cost)", value: $cost, in: 5...500, step: 5)
                    Button("Add") {
                        store.data.wishes.append(Wish(emoji: emoji, name: name, cost: cost))
                        name = ""
                    }
                    .disabled(name.isEmpty)
                }
            }
            Section("Redeemed") {
                if store.data.redemptions.isEmpty {
                    Text("Nothing yet. Keep watering!").foregroundStyle(.secondary)
                }
                ForEach(store.data.redemptions.reversed()) { r in
                    Text("\(r.wishName) · 🪙 \(r.cost) · \(r.date.formatted(date: .abbreviated, time: .omitted))")
                }
            }
        }
    }
}
