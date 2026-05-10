import SwiftUI

struct PrayerTrackerCardView: View {
    
    @StateObject private var tracker = PrayerTrackerManager()
    @Environment(\.scenePhase) private var scenePhase
    
    let prayers = [
        "Sübh",
        "Zöhr",
        "Əsr",
        "Məğrib",
        "İşa"
    ]
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            
            Text("Namaz izləyicisi")
                .font(AppFonts.SystemFont.body())
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                
                ForEach(prayers, id: \.self) { prayer in
                    
                    VStack(spacing: 8) {
                        
                        Button {
                            tracker.togglePrayer(prayer)
                        } label: {
                            
                            Circle()
                                .fill(
                                    tracker.isCompleted(prayer)
                                    ? AppColors.error
                                    : AppColors.textSecondary.opacity(0.2)
                                )
                                .frame(width: 44, height: 44)
                        }
                        
                        Text(prayer)
                            .font(AppFonts.SystemFont.body2())
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.card)
        .cornerRadius(12)
        .onAppear {
            tracker.load()
        }
        .onChange(of:scenePhase) { _, newPhase in
            
            if newPhase == .active {
                tracker.load()
            }
        }
    }
}

#Preview {
PrayerTrackerCardView()
}
