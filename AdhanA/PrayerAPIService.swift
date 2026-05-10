import Foundation



final class PrayerAPIService {
   
    func fetchPrayerTimes(lat: Double, lon: Double) async throws -> PrayerResponse {
       
        let urlString = """
        https://api.aladhan.com/v1/timings?latitude=\(lat)&longitude=\(lon)&method=2
        """
       
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
       
        let (data, _) = try await URLSession.shared.data(from: url)
       
        let decoded = try JSONDecoder().decode(PrayerResponse.self, from: data)
       
        return decoded
    }
}
