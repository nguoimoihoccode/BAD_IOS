import Foundation

protocol CommunityRepository {
    func getAnnouncements() async -> Result<[CommunityAnnouncement], Error>
    func getActiveMembers() async -> Result<[CommunityMember], Error>
    func getTopPlayers() async -> Result<[CommunityMember], Error>
    func getPoll() async -> Result<CommunityPoll, Error>
    func getRecentMessages() async -> Result<[ChatMessage], Error>
    func voteInPoll(optionId: String) async -> Result<CommunityPoll, Error>
    func sendChatMessage(text: String) async -> Result<ChatMessage, Error>
}
