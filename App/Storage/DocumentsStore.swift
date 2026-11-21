// User data lives in Documents/ so it survives Sideloadly's 7-day re-signs and reinstalls, and
// shows up in the Files app ("On My iPad › Mission Planner") and Finder/iTunes file sharing
// (UIFileSharingEnabled + LSSupportsOpeningDocumentsInPlace in Info.plist).
// Folder names follow desktop Mission Planner's Documents\Mission Planner layout.

import Foundation

final class DocumentsStore {
    static let shared = DocumentsStore()

    let root: URL
    let tlogs: URL
    let params: URL
    let missions: URL
    let tiles: URL

    private init() {
        let fm = FileManager.default
        root = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        tlogs = root.appendingPathComponent("logs", isDirectory: true)
        params = root.appendingPathComponent("params", isDirectory: true)
        missions = root.appendingPathComponent("missions", isDirectory: true)
        tiles = root.appendingPathComponent("tiles", isDirectory: true)
        for dir in [tlogs, params, missions, tiles] {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }

    func tlogFiles() -> [URL] {
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: tlogs, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles])) ?? []
        return urls.filter { $0.pathExtension.lowercased() == "tlog" }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }
    }
}
