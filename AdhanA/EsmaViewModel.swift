import Foundation
import SwiftUI
import Combine

final class EsmaViewModel: ObservableObject {
    
    @Published var currentIndex: Int = 0
    @Published var mode: Mode = .daily
    
    enum Mode {
        case daily
        case browsing
    }
    
    let list: [Esma] = esmaList
    
    var dailyIndex: Int {
        
        let day = Calendar.current.ordinality(
            of: .day,
            in: .year,
            for: Date()
        ) ?? 1
        
        return day % list.count
    }
    
    init() {
        currentIndex = dailyIndex
    }
    
    func next() {
        currentIndex = (currentIndex + 1) % list.count
        mode = .browsing
    }
    
    func previous() {
        currentIndex = (currentIndex - 1 + list.count) % list.count
        mode = .browsing
    }
    
    func goToToday() {
        currentIndex = dailyIndex
        mode = .daily
    }
}
