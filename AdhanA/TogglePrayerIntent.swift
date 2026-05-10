import AppIntents

struct TogglePrayerIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Toggle Prayer"
    
    @Parameter(title: "Prayer")
    var prayer: String
    
    init() { }
    
    init(prayer: String) {
        self.prayer = prayer
    }
    
    func perform() async throws -> some IntentResult {
        
        let defaults = UserDefaults(
            suiteName: "group.com.adhan.shared"
        )
        
        let key = "completed_prayers"
        
        var prayers = Set(
            defaults?.array(forKey: key) as? [String] ?? []
        )
        
        if prayers.contains(prayer) {
            prayers.remove(prayer)
        } else {
            prayers.insert(prayer)
        }
        
        defaults?.set(Array(prayers), forKey: key)
        
        return .result()
    }
}
