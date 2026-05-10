import SwiftUI

struct AppContainer<Content: View>: View {
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                AppColors.backgroundColor
                    .ignoresSafeArea()
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal, AppSpacing.md)
            }
        }
    }
}
