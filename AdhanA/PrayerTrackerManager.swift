import Foundation
import Combine



final class PrayerTrackerManager: ObservableObject {
   
    @Published var completedPrayers: Set<String> = []
   
    private let prayersKey = "completed_prayers"
    private let dateKey = "completed_prayers_date"
    private let sharedDefaults = UserDefaults(
        suiteName: "group.com.adhan.shared"
        )
   
    init() {
        load()
        resetIfNeeded()
    }
   
    // MARK: - Toggle
   
    func togglePrayer(_ prayer: String) {
        if completedPrayers.contains(prayer) {
            completedPrayers.remove(prayer)
        } else {
            completedPrayers.insert(prayer)
        }
       
        save()
    }
   
    // MARK: - Check
   
    func isCompleted(_ prayer: String) -> Bool {
        completedPrayers.contains(prayer)
    }
   
    // MARK: - Save
   
    private func save() {
        sharedDefaults?.set(
            Array(completedPrayers),
            forKey: prayersKey
        )
       
        sharedDefaults?.set(
            currentDate(),
            forKey: dateKey
        )
    }
   
    // MARK: - Load
   
    func load() {
        guard let saved = sharedDefaults?.array(forKey: prayersKey) as? [String] else {
            return
        }
       
        completedPrayers = Set(saved)
    }
   
    // MARK: - Reset
   
    private func resetIfNeeded() {
        let savedDate = sharedDefaults?.string(forKey: dateKey)
       
        if savedDate != currentDate() {
            completedPrayers.removeAll()
            save()
        }
    }
   
    // MARK: - Date
   
    private func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
       
        return formatter.string(from: Date())
    }
}
