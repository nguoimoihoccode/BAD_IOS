import Foundation

struct CommunityAnnouncement: Identifiable {
    let id: String
    let title: String
    let imageUrl: String
    let tag: String
}

struct CommunityMember: Identifiable {
    let id: String
    let name: String
    let avatarUrl: String?
    let isOnline: Bool
    let badge: String?
    let activity: String?
    let points: Int?
}

struct PollOption: Identifiable, Hashable {
    let id: String
    let text: String
    var votesPercent: Double
}

struct CommunityPoll {
    let id: String
    let question: String
    var options: [PollOption]
    var totalVotes: Int
    let daysLeft: Int
    var selectedOptionId: String?
}

struct ChatMessage: Identifiable {
    let id: String
    let senderName: String
    let senderAvatarUrl: String?
    let text: String
}
