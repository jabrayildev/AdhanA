import SwiftUI

struct HomeView: View {
    
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        AppContainer {
            VStack {
                HStack {
                    Text(locationManager.city)
                        .font(AppFonts.SystemFont.title())
                        .foregroundColor(AppColors.textThird)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                AdhanCardView()
                
                PrayerTrackerCardView()
                
                EsmaCardView()
                
                Spacer()
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
}

#Preview {
    HomeView()
}
