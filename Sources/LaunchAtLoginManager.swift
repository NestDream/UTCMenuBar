import Foundation
import ServiceManagement

enum BundleInfo {
    static var shortVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }
    static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }
    static let releasesURL = URL(string: "https://github.com/NestDream/UTCMenuBar/releases")!
}


@MainActor
enum LaunchAtLoginManager {
    enum LaunchAtLoginError: Error {
        case registrationFailed(underlying: Error)
        case unregistrationFailed(underlying: Error)
    }

    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static var status: SMAppService.Status {
        SMAppService.mainApp.status
    }

    static var requiresApproval: Bool {
        SMAppService.mainApp.status == .requiresApproval
    }

    static func setEnabled(_ enabled: Bool) throws {
        let service = SMAppService.mainApp
        do {
            if enabled {
                try service.register()
            } else if service.status != .notRegistered {
                try service.unregister()
            }
        } catch {
            throw enabled
                ? LaunchAtLoginError.registrationFailed(underlying: error)
                : LaunchAtLoginError.unregistrationFailed(underlying: error)
        }
    }

    static func openLoginItemsInSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
