import Foundation

struct DeviceSession: Identifiable {
    let id: String
    let deviceName: String
    let lastActive: String
    let isCurrent: Bool
}
