import SwiftUI

@main
struct MissionPlannerPadApp: App {
    @StateObject private var link = LinkManager()

    init() {
        _ = DocumentsStore.shared // create Documents/logs, params, missions, tiles on first launch
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(link)
                .environmentObject(link.vehicle)
                .environmentObject(link.params)
                .environmentObject(link.commands)
        }
    }
}
