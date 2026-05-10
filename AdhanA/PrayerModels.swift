import Foundation



struct PrayerResponse: Codable {
    let data: PrayerData
}



struct PrayerData: Codable {
    let timings: PrayerTimings
    let date: DateInfo
}



// MARK: - 6 Namaz Times
struct PrayerTimings: Codable {
    let imsak: String?
    let fajr: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
   
    enum CodingKeys: String, CodingKey {
        case imsak = "Imsak"
        case fajr = "Fajr"
        case dhuhr = "Dhuhr"
        case asr = "Asr"
        case maghrib = "Maghrib"
        case isha = "Isha"
    }
}



// MARK: - Hijri Date Only
struct DateInfo: Codable {
    let hijri: HijriDate
}



struct HijriDate: Codable {
    let date: String
}
