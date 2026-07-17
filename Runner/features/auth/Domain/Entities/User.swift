import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let shortId: String
    let email: String
    let username: String
    let fullName: String?
    let phone: String?
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case shortId = "short_id"
        case email
        case username
        case fullName = "full_name"
        case phone
        case avatarUrl = "avatar_url"
    }
}
