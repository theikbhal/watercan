import SwiftUI

struct WaterAnimation: View {
    @State private var fall = false
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                Image(systemName: "drop.fill")
                    .foregroundStyle(.blue)
                    .offset(x: CGFloat(i - 3) * 14, y: fall ? 60 : -50)
                    .opacity(fall ? 0 : 1)
                    .animation(.easeIn(duration: 0.8).delay(Double(i) * 0.1), value: fall)
            }
        }
        .onAppear { fall = true }
    }
}

struct TodayView: View {
    @EnvironmentObject var store: Store
    @State private var date = Date()
    @State private var hours: Double = 0
    @State private var rate: Double = 0
    @State private var showWater = false

    private func bind<T>(_ kp: WritableKeyPath<DayEntry, T>) -> Binding<T> {
        Binding(
            get: { store.entry(for: date)[keyPath: kp] },
            set: { v in store.update(date) { $0[keyPath: kp] = v } }
        )
    }

    private var plant: String {
        switch store.streak {
        case 0: return "🌰"
        case 1...2: return "🌱"
        case 3...6: return "🌿"
        case 7...13: return "🪴"
        case 14...29: return "🌳"
        default: return "🌸"
        }
    }

    private func play() {
        withAnimation { showWater = true }
        Task {
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            withAnimation { showWater = false }
        }
    }

    var body: some View {
        let e = store.entry(for: date)
        let sym = store.data.currencySymbol
        let target = store.data.dailyTarget
        let energy = min(1.0, (e.watered ? 0.4 : 0) + Double(min(e.tries, 5)) * 0.12)

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(date.formatted(date: .complete, time: .omitted)).font(.title2.bold())
                        DatePicker("Date", selection: $date, displayedComponents: .date).labelsHidden()
                    }
                    Spacer()
                    ZStack {
                        Text(plant)
                            .font(.system(size: 90))
                            .scaleEffect(showWater ? 1.15 : 1)
                        if showWater { WaterAnimation() }
                    }
                    .frame(width: 140, height: 140)
                }

                Toggle(isOn: Binding(
                    get: { e.watered },
                    set: { v in
                        store.update(date) { $0.watered = v }
                        if v { play() }
                    })
                ) {
                    Text("💧 I watered my plant (I put in my effort)").font(.title3)
                }
                .toggleStyle(.checkbox)

                GroupBox("⚡ Energy") {
                    ProgressView(value: energy).tint(.yellow).padding(.vertical, 4)
                }

                GroupBox("💰 Earnings") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Earned on this day")
                            TextField("0", value: bind(\.earned), format: .number)
                                .textFieldStyle(.roundedBorder).frame(width: 120)
                            Text(sym)
                        }
                        ProgressView(value: target > 0 ? min(1, e.earned / target) : 0)
                        Text(e.earned >= target
                             ? "🎉 Minimum reached! +5 bonus coins"
                             : "Earn at least \(sym)\(Int(target)). \(sym)\(Int(target - e.earned)) to go.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("🧮 Calculator") {
                    HStack {
                        TextField("Hours", value: $hours, format: .number)
                            .textFieldStyle(.roundedBorder).frame(width: 80)
                        Text("×")
                        TextField("Rate", value: $rate, format: .number)
                            .textFieldStyle(.roundedBorder).frame(width: 80)
                        Text("= \(sym)\(Int(hours * rate))").bold()
                        Spacer()
                        Button("Add to today") {
                            let add = hours * rate
                            store.update(date) { $0.earned += add }
                        }
                        .disabled(hours * rate <= 0)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("🤲 Dua & tries") {
                    Stepper("Tries today: \(e.tries)  (up to 5 earn coins)", value: bind(\.tries), in: 0...50)
                        .padding(.vertical, 4)
                }

                GroupBox("📁 Project / event") {
                    HStack {
                        TextField("Project", text: bind(\.project)).textFieldStyle(.roundedBorder)
                        TextField("Event", text: bind(\.event)).textFieldStyle(.roundedBorder)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("📝 Notes") {
                    TextEditor(text: bind(\.notes))
                        .frame(height: 120)
                        .font(.body)
                }

                Text("Coins earned on this day: 🪙 \(store.coins(for: e))").font(.headline)
            }
            .padding(24)
        }
    }
}
