import SwiftUI

struct AdhanCardView: View {
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var prayerData: PrayerData?
    @State private var nextPrayer: Prayer?
    
    @State private var now = Date()
    @State private var timer: Timer?
    
    let api = PrayerAPIService()
    
    // MARK: - Model
    struct Prayer {
        let name: String
        let time: Date
    }
    
    var body: some View {
        let time = timeRemaining()
        let next = nextPrayer?.name
        
        VStack(spacing: AppSpacing.sm) {
            
            Text("Növbəti namaz")
                .font(AppFonts.SystemFont.body2())
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
            
            Text("\(next ?? "-") namazı")
                .font(AppFonts.SystemFont.largeTitle())
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
            
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(time.main)
                    .font(AppFonts.TimerFont.main())
                    .foregroundColor(AppColors.textPrimary)
                
                Text(time.seconds)
                    .font(AppFonts.TimerFont.seconds())
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            
            HStack {
                Text(currentDate())
                    .font(AppFonts.SystemFont.body2())
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text(formatHijriDate(prayerData?.date.hijri.date ?? ""))
                    .font(AppFonts.SystemFont.body2())
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, 20)
            
            Rectangle()
                .fill(AppColors.textSecondary)
                .frame(height: 1)
                .padding(.horizontal, 8)
            
            HStack {
                prayerColumn("İmsak", prayerData?.timings.imsak ?? "-", next)
                prayerColumn("Sübh", prayerData?.timings.fajr ?? "-", next)
                prayerColumn("Zöhr", prayerData?.timings.dhuhr ?? "-", next)
                prayerColumn("Əsr", prayerData?.timings.asr ?? "-", next)
                prayerColumn("Məğrib", prayerData?.timings.maghrib ?? "-", next)
                prayerColumn("İşa", prayerData?.timings.isha ?? "-", next)
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.card)
        .cornerRadius(12)
        
        .onAppear {
            locationManager.requestLocation()
            startTimer()
            observeDayChange()
        }
        
        .onChange(of: locationManager.latitude) { _ in
            loadData()
        }
    }
    
    // MARK: - UI Helper
    
    func prayerColumn(_ title: String, _ time: String, _ next: String?) -> some View {
        let isActive = title == next
        
        return VStack {
            Text(title)
                .font(AppFonts.SystemFont.body2())
                .foregroundColor(isActive ? AppColors.error : AppColors.textPrimary)
                .frame(maxWidth: .infinity)
            
            Text(time)
                .font(AppFonts.SystemFont.body())
                .foregroundColor(isActive ? AppColors.error : AppColors.textPrimary)
                .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - TIMER
    
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.now = Date()
        }
    }
    
    func timeRemaining() -> (main: String, seconds: String) {
        guard let next = nextPrayer else {
            return ("--:--", ":--")
        }
        
        let diff = Int(next.time.timeIntervalSince(now))
        
        if diff <= 0 {
            return ("00:00", ":00")
        }
        
        let hours = diff / 3600
        let minutes = (diff % 3600) / 60
        let seconds = diff % 60
        
        let main = String(format: "%02d:%02d", hours, minutes)
        let sec = String(format: ":%02d", seconds)
        
        return (main, sec)
    }
    
    // MARK: - LOAD DATA
    
    func loadData() {
        Task {
            let cache = PrayerCacheManager()
            
            if let cached = cache.load() {
                self.prayerData = cached
                self.nextPrayer = calculateNextPrayer(from: cached)
                return
            }
            
            guard let lat = locationManager.latitude,
                  let lon = locationManager.longitude else {
                return
            }
            
            do {
                let result = try await api.fetchPrayerTimes(lat: lat, lon: lon)
                
                DispatchQueue.main.async {
                    self.prayerData = result.data
                    self.nextPrayer = calculateNextPrayer(from: result.data)
                    cache.save(data: result.data)
                }
                
            } catch {
                print("API Error:", error)
            }
        }
    }
    
    // MARK: - DATE
    
    func currentDate() -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "az_AZ")
        
        let date = Date()
        let result = formatter.string(from: date)
        
        return result
    }
    
    // MARK: - TIME LOGIC
    
    func parseTime(_ time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if let parsed = formatter.date(from: time) {
            let comp = Calendar.current.dateComponents([.hour, .minute], from: parsed)
            return Calendar.current.date(
                bySettingHour: comp.hour ?? 0,
                minute: comp.minute ?? 0,
                second: 0,
                of: today
            )
        }
        return nil
    }
    
    func buildPrayers(from data: PrayerData) -> [Prayer] {
        let t = data.timings
        
        return [
            Prayer(name: "İmsak", time: parseTime(t.imsak ?? "") ?? Date()),
            Prayer(name: "Sübh", time: parseTime(t.fajr) ?? Date()),
            Prayer(name: "Zöhr", time: parseTime(t.dhuhr) ?? Date()),
            Prayer(name: "Əsr", time: parseTime(t.asr) ?? Date()),
            Prayer(name: "Məğrib", time: parseTime(t.maghrib) ?? Date()),
            Prayer(name: "İşa", time: parseTime(t.isha) ?? Date())
        ]
    }
    
    func calculateNextPrayer(from data: PrayerData) -> Prayer? {
        let now = Date()
        let prayers = buildPrayers(from: data)
        
        if let next = prayers.first(where: { $0.time > now }) {
            return next
        }
        
        return prayers.first
    }
    
    func updateNextPrayer() {
        guard let data = prayerData else { return }
        
        let prayers = buildPrayers(from: data)
        let now = Date()
        
        if let next = prayers.first(where: { $0.time > now }) {
            self.nextPrayer = next
        } else {
            self.nextPrayer = prayers.first
        }
    }
    
    func formatHijriDate(_ raw: String) -> String {
        let parts = raw.split(separator: "-")
        
        guard parts.count == 3 else {return raw}
        
        let day = parts[0]
        let month = parts[1]
        let year = parts[2]
        
        let months:[String: String] = [
            "01": "Məhərrəm",
            "02": "Səfər",
            "03": "Rəbiül-əvvəl",
            "04": "Rəbiül-axır",
            "05": "Cümədəl-ula",
            "06": "Cümədəl-axır",
            "07": "Rəcəb",
            "08": "Şaban",
            "09": "Ramazan",
            "10": "Şəvval",
            "11": "Zülqədə",
            "12": "Zülhiccə",
        ]
        
        let monthName = months[String(month)] ?? ""
        
        return "\(day) \(monthName) \(year)"
    }
    
    func observeDayChange() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSCalendarDayChanged,
            object: nil,
            queue: .main
        ) { _ in
            
            print("New day detected")
            
            loadData()
        }
    }
}
