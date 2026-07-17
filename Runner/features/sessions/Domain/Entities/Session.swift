import Foundation

struct SessionParticipant: Identifiable {
    let id: String
    let name: String
    let avatarUrl: String?
    let level: String
    let isHost: Bool
}

struct Session: Identifiable {
    let id: String
    let title: String
    let date: String
    let time: String
    let location: String
    let duration: String
    let maxParticipants: Int
    let courtFee: Double
    let shuttlecockFee: Double
    let totalFee: Double
    var participants: [SessionParticipant]
    var isJoined: Bool
    var paymentStatus: String
}
