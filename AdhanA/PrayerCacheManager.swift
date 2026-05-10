import Foundation



final class PrayerCacheManager {
   
    private let key = "prayer_cache_key"
    private let dateKey = "prayer_cache_date"
   
    func save(data: PrayerData) {
        do {
            let encoded = try JSONEncoder().encode(data)
            UserDefaults.standard.set(encoded, forKey: key)
            UserDefaults.standard.set(currentDate(), forKey: dateKey)
        } catch {
            print("Cache Save Error:", error)
        }
    }
   
    func load() -> PrayerData? {
        guard let savedDate = UserDefaults.standard.string(forKey: dateKey),
              savedDate == currentDate(),
              let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
       
        do {
            return try JSONDecoder().decode(PrayerData.self, from: data)
        } catch {
            print("Cache Decode Error:", error)
            return nil
        }
    }
   
    private func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
