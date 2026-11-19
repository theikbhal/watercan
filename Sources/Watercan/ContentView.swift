import SwiftUI

enum Tab: String, CaseIterable, Identifiable {
    case today = "Today", reports = "Reports", wishes = "Wishes", badges = "Badges", settings = "Settings"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .today: return "drop.fill"
        case .reports: return "chart.bar.xaxis"
        case .wishes: return "gift.fill"
        case .badges: return "rosette"
        case .settings: return "gearshape"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var store: Store
    @State private var tab: Tab? = .today

    var body: some View {
        NavigationSplitView {
            List(Tab.allCases, selection: $tab) { t in
                Label(t.rawValue, systemImage: t.icon)
            }
            .navigationSplitViewColumnWidth(min: 190, ideal: 210)
            .safeAreaInset(edge: .bottom) { StatsHeader().padding() }
        } detail: {
            switch tab ?? .today {
            case .today: TodayView()
            case .reports: ReportsView()
            case .wishes: WishesView()
            case .badges: BadgesView()
            case .settings: SettingsView()
            }
        }
    }
}

struct StatsHeader: View {
    @EnvironmentObject var store: Store
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Level \(store.level)").font(.headline)
            ProgressView(value: store.levelProgress)
            HStack {
                Text("🪙 \(store.balance)")
                Spacer()
                Text("🔥 \(store.streak)")
            }
            .font(.subheadline)
        }
    }
}
