import Foundation

class CommunityRepositoryImpl: CommunityRepository {
    private var announcements = [
        CommunityAnnouncement(
            id: "announce-1",
            title: "Summer Finals: Registration now open!",
            imageUrl: "https://images.unsplash.com/photo-1560089000-7433a4ebbd64",
            tag: "Tournament"
        )
    ]

    private var members = [
        CommunityMember(id: "m1", name: "Sarah", avatarUrl: nil, isOnline: true, badge: "Gold", activity: "Elite Active", points: 1200),
        CommunityMember(id: "m2", name: "Marcus", avatarUrl: nil, isOnline: true, badge: "Silver", activity: "Expert Player", points: 980),
        CommunityMember(id: "m3", name: "Trần Anh Tuấn", avatarUrl: nil, isOnline: true, badge: "Gold", activity: "Champion", points: 1500),
        CommunityMember(id: "m4", name: "Lê Minh Hạnh", avatarUrl: nil, isOnline: false, badge: "Bronze", activity: "Intermediate", points: 600),
        CommunityMember(id: "m5", name: "Nguyễn Quốc Cường", avatarUrl: nil, isOnline: false, badge: nil, activity: "Regular", points: 450)
    ]

    private var poll = CommunityPoll(
        id: "poll-1",
        question: "Which venue for the summer tournament?",
        options: [
            PollOption(id: "opt-1", text: "City Arena", votesPercent: 38.0),
            PollOption(id: "opt-2", text: "Eastside Sports Center", votesPercent: 42.0),
            PollOption(id: "opt-3", text: "Kinetic Badminton Court", votesPercent: 20.0)
        ],
        totalVotes: 128,
        daysLeft: 2,
        selectedOptionId: nil
    )

    private var messages = [
        ChatMessage(id: "msg-1", senderName: "Sarah", senderAvatarUrl: nil, text: "Who is up for a session this Tuesday?"),
        ChatMessage(id: "msg-2", senderName: "Marcus", senderAvatarUrl: nil, text: "I'm in! Let's book Court 3.")
    ]

    func getAnnouncements() async -> Result<[CommunityAnnouncement], Error> { return .success(announcements) }
    func getActiveMembers() async -> Result<[CommunityMember], Error> { return .success(members.filter { $0.isOnline }) }
    func getTopPlayers() async -> Result<[CommunityMember], Error> { return .success(members.sorted { ($0.points ?? 0) > ($1.points ?? 0) }) }
    func getPoll() async -> Result<CommunityPoll, Error> { return .success(poll) }
    func getRecentMessages() async -> Result<[ChatMessage], Error> { return .success(messages) }

    func voteInPoll(optionId: String) async -> Result<CommunityPoll, Error> {
        if poll.selectedOptionId != nil { return .success(poll) }
        
        for idx in 0..<poll.options.count {
            if poll.options[idx].id == optionId {
                poll.options[idx].votesPercent += 1.0
            }
        }
        
        poll.totalVotes += 1
        poll.selectedOptionId = optionId
        return .success(poll)
    }

    func sendChatMessage(text: String) async -> Result<ChatMessage, Error> {
        let msg = ChatMessage(id: "msg-\(Date().timeIntervalSince1970)", senderName: "CurrentUser", senderAvatarUrl: nil, text: text)
        messages.append(msg)
        return .success(msg)
    }
}
