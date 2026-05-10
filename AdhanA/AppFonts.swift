import SwiftUI

struct AppFonts {
    
    // MARK: - System Font
    struct SystemFont {
        static func largeTitle() -> Font {
            .system(size: 24, weight: .medium)
        }
        
        static func title() -> Font {
            .system(size: 16, weight: .regular)
        }
        
        static func body2() -> Font {
            .system(size: 14, weight: .regular)
        }
        
        static func body() -> Font {
            .system(size: 15, weight: .medium)
        }
    }
    
    // MARK: - Menlo
    struct TimerFont {
        
        static func main() -> Font {
            .custom("Menlo", size: 68)
        }
        
        static func seconds() -> Font {
            .custom("Menlo", size: 32)
        }
    }
}
