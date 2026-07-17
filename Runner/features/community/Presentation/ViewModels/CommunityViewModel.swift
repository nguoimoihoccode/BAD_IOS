import Foundation
import Combine

@MainActor
class CommunityViewModel: ObservableObject {
    @Published var announcements: [CommunityAnnouncement] = []
    @Published var activeMembers: [CommunityMember] = []
    @Published var topPlayers: [CommunityMember] = []
    @Published var poll: CommunityPoll? = nil
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let repository: CommunityRepository

    init(repository: CommunityRepository = ServiceLocator.shared.communityRepository) {
        self.repository = repository
        loadCommunityData()
    }

    func loadCommunityData() {
        isLoading = true
        errorMessage = nil
        Task {
            let resAnnounce = await repository.getAnnouncements()
            let resActive = await repository.getActiveMembers()
            let resTop = await repository.getTopPlayers()
            let resPoll = await repository.getPoll()
            let resMsg = await repository.getRecentMessages()
            isLoading = false
            
            if case .success(let announce) = resAnnounce,
               case .success(let active) = resActive,
               case .success(let top) = resTop,
               case .success(let pollObj) = resPoll,
               case .success(let msgList) = resMsg {
                self.announcements = announce
                self.activeMembers = active
                self.topPlayers = top
                self.poll = pollObj
                self.messages = msgList
            } else {
                self.errorMessage = "Failed to load community features"
            }
        }
    }

    func voteInPoll(optionId: String) {
        Task {
            let res = await repository.voteInPoll(optionId: optionId)
            if case .success(let updatedPoll) = res {
                self.poll = updatedPoll
            }
        }
    }

    func sendMessage(text: String) {
        if text.isEmpty { return }
        Task {
            let _ = await repository.sendChatMessage(text: text)
            loadCommunityData()
        }
    }
}
