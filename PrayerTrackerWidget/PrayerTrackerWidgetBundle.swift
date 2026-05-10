import WidgetKit
import SwiftUI

@main
struct PrayerTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        PrayerTrackerWidget()
        PrayerTrackerWidgetControl()
    }
}
