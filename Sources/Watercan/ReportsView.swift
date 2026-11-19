import SwiftUI
import Charts

enum Period: String, CaseIterable, Identifiable {
    case daily = "Daily", weekly = "Weekly", monthly = "Monthly", quarterly = "Quarterly", yearly = "Yearly"
    var id: String { rawValue }
}

struct Row: Identifiable {
    var id: String { entry.key }
    let date: Date
    let entry: DayEntry
}

struct Bucket: Identifiable {
    let id: Int
    let label: String
    let value: Double
}

struct Ring: View {
    let progress: Double
    var body: some View {
        ZStack {
            Circle().stroke(Color.gray.opacity(0.2), lineWidth: 14)
            Circle().trim(from: 0, to: min(1, progress))
                .stroke(Color.green, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
            Text("\(Int(progress * 100))%").font(.title2.bold())
        }
    }
}

struct Tile: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3.bold())
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct ReportsView: View {
    @EnvironmentObject var store: Store
    @State private var period: Period = .weekly
    @State private var offset = 0
    @State private var filter = ""

    private var cal: Calendar { .current }

    private var range: (start: Date, end: Date) {
        let now = Date()
        switch period {
        case .daily:
            let d = cal.date(byAdding: .day, value: offset, to: cal.startOfDay(for: now))!
            return (d, cal.date(byAdding: .day, value: 1, to: d)!)
        case .weekly:
            let b = cal.date(byAdding: .weekOfYear, value: offset, to: now)!
            let i = cal.dateInterval(of: .weekOfYear, for: b)!
            return (i.start, i.end)
        case .monthly:
            let b = cal.date(byAdding: .month, value: offset, to: now)!
            let i = cal.dateInterval(of: .month, for: b)!
            return (i.start, i.end)
        case .quarterly:
            let b = cal.date(byAdding: .month, value: offset * 3, to: now)!
            let c = cal.dateComponents([.year, .month], from: b)
            let qm = ((c.month! - 1) / 3) * 3 + 1
            let s = cal.date(from: DateComponents(year: c.year, month: qm, day: 1))!
            return (s, cal.date(byAdding: .month, value: 3, to: s)!)
        case .yearly:
            let b = cal.date(byAdding: .year, value: offset, to: now)!
            let i = cal.dateInterval(of: .year, for: b)!
            return (i.start, i.end)
        }
    }

    private var monthly: Bool { period == .quarterly || period == .yearly }

    private var rows: [Row] {
        var out: [Row] = []
        var d = range.start
        while d < range.end {
            let e = store.entry(for: d)
            if filter.isEmpty
                || e.project.localizedCaseInsensitiveContains(filter)
                || e.event.localizedCaseInsensitiveContains(filter) {
                out.append(Row(date: d, entry: e))
            }
            d = cal.date(byAdding: .day, value: 1, to: d)!
        }
        return out
    }

    private var dayCount: Int {
        cal.dateComponents([.day], from: range.start, to: range.end).day ?? 1
    }

    private var buckets: [Bucket] {
        if monthly {
            var out: [Bucket] = []
            var m = range.start
            var i = 0
            while m < range.end {
                let v = rows.filter { cal.isDate($0.date, equalTo: m, toGranularity: .month) }
                    .reduce(0) { $0 + $1.entry.earned }
                out.append(Bucket(id: i, label: m.formatted(.dateTime.month(.abbreviated)), value: v))
                m = cal.date(byAdding: .month, value: 1, to: m)!
                i += 1
            }
            return out
        }
        return rows.enumerated().map {
            Bucket(id: $0.offset,
                   label: $0.element.date.formatted(.dateTime.day().month(.abbreviated)),
                   value: $0.element.entry.earned)
        }
    }

    private var title: String {
        let last = cal.date(byAdding: .day, value: -1, to: range.end)!
        switch period {
        case .daily: return range.start.formatted(date: .complete, time: .omitted)
        case .weekly: return "\(range.start.formatted(.dateTime.day().month(.abbreviated))) – \(last.formatted(.dateTime.day().month(.abbreviated).year()))"
        case .monthly: return range.start.formatted(.dateTime.month(.wide).year())
        case .quarterly:
            let q = (cal.component(.month, from: range.start) - 1) / 3 + 1
            return "Q\(q) \(cal.component(.year, from: range.start))"
        case .yearly: return String(cal.component(.year, from: range.start))
        }
    }

    var body: some View {
        let sym = store.data.currencySymbol
        let earned = rows.reduce(0) { $0 + $1.entry.earned }
        let target = store.data.dailyTarget * Double(dayCount)
        let progress = target > 0 ? earned / target : 0
        let wateredDays = rows.filter { $0.entry.watered }.count
        let tries = rows.reduce(0) { $0 + $1.entry.tries }
        let coins = rows.reduce(0) { $0 + store.coins(for: $1.entry) }

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Picker("Period", selection: $period) {
                    ForEach(Period.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .onChange(of: period) { _, _ in offset = 0 }

                HStack {
                    Button { offset -= 1 } label: { Image(systemName: "chevron.left") }
                    Text(title).font(.title2.bold())
                    Button { offset += 1 } label: { Image(systemName: "chevron.right") }
                    Spacer()
                    TextField("Filter by project or event", text: $filter)
                        .textFieldStyle(.roundedBorder).frame(width: 260)
                }

                HStack(spacing: 20) {
                    Ring(progress: progress).frame(width: 130, height: 130)
                    VStack {
                        HStack {
                            Tile(title: "Earned", value: "\(sym)\(Int(earned))")
                            Tile(title: "Target", value: "\(sym)\(Int(target))")
                        }
                        HStack {
                            Tile(title: "Days watered", value: "\(wateredDays)/\(dayCount)")
                            Tile(title: "Tries", value: "\(tries)")
                            Tile(title: "Coins", value: "🪙 \(coins)")
                        }
                    }
                }

                GroupBox("Earnings") {
                    Chart {
                        ForEach(buckets) { b in
                            BarMark(x: .value("Day", b.label), y: .value("Earned", b.value))
                                .foregroundStyle(Color.green.gradient)
                        }
                        if !monthly && store.data.dailyTarget > 0 {
                            RuleMark(y: .value("Target", store.data.dailyTarget))
                                .lineStyle(StrokeStyle(dash: [4]))
                                .foregroundStyle(.orange)
                        }
                    }
                    .frame(height: 240)
                    .padding(.top, 8)
                }

                GroupBox("Notes, projects & events") {
                    VStack(alignment: .leading, spacing: 10) {
                        let withText = rows.filter {
                            !$0.entry.notes.isEmpty || !$0.entry.project.isEmpty || !$0.entry.event.isEmpty
                        }
                        if withText.isEmpty {
                            Text("Nothing logged for this period.").foregroundStyle(.secondary)
                        }
                        ForEach(withText) { r in
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(r.date.formatted(date: .abbreviated, time: .omitted)).bold()
                                    if !r.entry.project.isEmpty { Text("📁 \(r.entry.project)") }
                                    if !r.entry.event.isEmpty { Text("🎪 \(r.entry.event)") }
                                    Spacer()
                                    Text("\(sym)\(Int(r.entry.earned))")
                                }
                                if !r.entry.notes.isEmpty {
                                    Text(r.entry.notes).foregroundStyle(.secondary)
                                }
                            }
                            Divider()
                        }
                    }
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(24)
        }
    }
}
