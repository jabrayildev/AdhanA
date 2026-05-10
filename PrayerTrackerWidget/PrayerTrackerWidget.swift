import WidgetKit
import SwiftUI
import AppIntents

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(
            date: Date(),
            completedPrayers: []
        )
    }
    
    func getSnapshot(
        in context: Context,
        completion: @escaping (PrayerEntry) -> Void
    ) {
        completion(loadEntry())
    }
    
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<PrayerEntry>) -> Void
    ) {
        let entry = loadEntry()
        
        let timeline = Timeline(
            entries: [entry],
            policy: .after(Date().addingTimeInterval(300))
        )
        
        completion(timeline)
    }
    
    private func loadEntry() -> PrayerEntry {
        
        let defaults = UserDefaults(
            suiteName: "group.com.adhan.shared"
        )
        
        let prayers = Set(
            defaults?.array(
                forKey: "completed_prayers"
            ) as? [String] ?? []
        )
        
        return PrayerEntry(
            date: Date(),
            completedPrayers: prayers
        )
    }
}

// MARK: - Entry

struct PrayerEntry: TimelineEntry {
    let date: Date
    let completedPrayers: Set<String>
}

// MARK: - Widget View

struct PrayerTrackerWidgetEntryView: View {
    
    var entry: Provider.Entry
    
    let prayers = [
        "Sübh",
        "Zöhr",
        "Əsr",
        "Məğrib",
        "İşa"
    ]
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            Text("Namaz izləyicisi")
                .font(.system(size: 14, weight: .medium))
            
            HStack {
                
                ForEach(prayers, id: \.self) { prayer in
                    
                    VStack(spacing: 6) {
                        
                        Button(
                            intent: TogglePrayerIntent(
                                prayer: prayer
                            )
                        ) {
                            
                            Circle()
                                .fill(
                                    entry.completedPrayers.contains(prayer)
                                    ? Color.green
                                    : Color.gray.opacity(0.3)
                                )
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(.plain)
                        
                        Text(prayer)
                            .font(.system(size: 10))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget

struct PrayerTrackerWidget: Widget {
    
    let kind: String = "PrayerTrackerWidget"
    
    var body: some WidgetConfiguration {
        
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            
            PrayerTrackerWidgetEntryView(
                entry: entry
            )
        }
        .configurationDisplayName(
            "Prayer Tracker"
        )
        .description(
            "Track your daily prayers."
        )
        .supportedFamilies([
            .systemMedium
        ])
    }
}
