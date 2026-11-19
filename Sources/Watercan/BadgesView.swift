import SwiftUI

struct BadgesView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Level \(store.level) · best streak \(store.bestStreak) days").font(.title2.bold())
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 170))], spacing: 16) {
                    ForEach(store.badges) { b in
                        VStack(spacing: 6) {
                            Text(b.emoji).font(.system(size: 48))
                            Text(b.title).font(.headline)
                            Text(b.detail).font(.caption).foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                        .opacity(b.unlocked ? 1 : 0.3)
                        .saturation(b.unlocked ? 1 : 0)
                    }
                }
            }
            .padding(24)
        }
    }
}
