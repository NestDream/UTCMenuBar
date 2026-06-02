import Foundation

/// Abstraction over the launch-at-login mechanism so the Settings view model can
/// be unit-tested with a fake. The production implementation (backed by
/// `SMAppService`) lives in the app target.
@MainActor
public protocol LoginItemControlling {
    var isEnabled: Bool { get }
    var requiresApproval: Bool { get }
    func setEnabled(_ enabled: Bool) throws
}
