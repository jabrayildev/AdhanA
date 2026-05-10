import SwiftUI

struct EsmaCardView: View {
    
    @StateObject var vm = EsmaViewModel()
    
    var body: some View {
        
        let esma = vm.list[vm.currentIndex]
        
        VStack {
            
            VStack(alignment: .leading, spacing: 16) {
                
                // HEADER
                HStack(spacing: 10) {
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        
                        Text("Esma al-Husna")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(esma.nameLatin)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .overlay(Color.white.opacity(0.2))
                
                // ARABIC
                Text(esma.nameArabic)
                    .font(.system(size: 64, weight: .medium, design: .serif))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 6)
                
                // MEANING
                Text(esma.meaningAZ)
                    .font(AppFonts.SystemFont.body2())
                    .foregroundColor(.white.opacity(0.95))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
            }
            .padding(.vertical, AppSpacing.md)
            .padding(.horizontal, 18)
            .background(
                Color(AppColors.card)
            )
            .cornerRadius(12)
            
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    vm.next()
                }
            }
        }
        
    }
}
