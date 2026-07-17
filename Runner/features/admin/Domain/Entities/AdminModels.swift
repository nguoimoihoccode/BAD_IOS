import Foundation

struct MemberItem: Identifiable {
    let id: String
    let fullName: String
    let username: String
    let avatarUrl: String?
    var role: String // 'admin', 'member'
    let skillLevel: String
    var isBlocked: Bool
}

struct JoinRequestItem: Identifiable {
    let id: String
    let fullName: String
    let username: String
    let avatarUrl: String?
    let skillLevel: String
    let message: String
    let requestedAt: Date
}
