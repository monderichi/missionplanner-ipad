// Minimal UIKit stand-in so the app's non-UI sources (PlannerSettings, ManualControl) compile in the macOS harness.
// Only the symbols those files use. Notifications are real NotificationCenter names, so the harness can post them
// (e.g. simulate the app going to the background).
@_exported import Foundation

public final class UIApplication {
    public static let shared = UIApplication()
    public var isIdleTimerDisabled = false
    public static let willResignActiveNotification = Notification.Name("UIApplicationWillResignActiveNotification")
    public static let didBecomeActiveNotification = Notification.Name("UIApplicationDidBecomeActiveNotification")
    public static let didEnterBackgroundNotification = Notification.Name("UIApplicationDidEnterBackgroundNotification")
    public static let willEnterForegroundNotification = Notification.Name("UIApplicationWillEnterForegroundNotification")
}
