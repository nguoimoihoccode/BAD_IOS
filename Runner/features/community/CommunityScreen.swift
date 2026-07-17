import SwiftUI
import UIKit

struct CommunityScreen: View {
    var onPlayerClick: (String) -> Void = { _ in }
    var onLeaderboardClick: () -> Void = {}
    var onMembersClick: () -> Void = {}
    var onJoinRequestsClick: () -> Void = {}
    @ObservedObject var viewModel: CommunityViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Community")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                    .padding(.top, 16)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.KineticGreen))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.ErrorRed)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                } else {
                    adminConsoleStrip

                    if let announce = viewModel.announcements.first {
                        announcementCard(announce)
                    }

                    activeNowSection

                    if let poll = viewModel.poll {
                        pollCard(poll)
                    }

                    if !viewModel.messages.isEmpty {
                        groupChatPreview
                    }

                    topPlayersSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
    }

    private var adminConsoleStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.primary)
                Text("Admin Control Panel")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.primary)
            }

            HStack(spacing: 12) {
                Button(action: onMembersClick) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 14))
                        Text("Members")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.primary.opacity(0.35), lineWidth: 1)
                    )
                }

                Button(action: onJoinRequestsClick) {
                    HStack(spacing: 6) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 14))
                        Text("Requests")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.primary.opacity(0.35), lineWidth: 1)
                    )
                }
            }
        }
        .padding(16)
        .background(AppTheme.primary.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.primary.opacity(0.15), lineWidth: 1)
        )
        .cornerRadius(12)
    }

    private func announcementCard(_ announce: CommunityAnnouncement) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [AppTheme.primary, Color(red: 0, green: 0.3, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 180)
            .cornerRadius(12)

            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 180)
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 8) {
                Text(announce.tag.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .kerning(0.8)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.primaryContainer)
                    .cornerRadius(50)

                Text(announce.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(16)
        }
    }

    private var activeNowSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Active Now")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Spacer()
                let onlineCount = viewModel.activeMembers.filter(\.isOnline).count
                Text("\(onlineCount) Online")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.KineticGreen)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.activeMembers) { member in
                        Button(action: { onPlayerClick(member.id) }) {
                            VStack(spacing: 4) {
                                ZStack(alignment: .bottomTrailing) {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.KineticGreen.opacity(0.1))
                                            .frame(width: 48, height: 48)
                                        Text(String(member.name.prefix(1)).uppercased())
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(AppTheme.KineticGreen)
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(member.isOnline ? AppTheme.primaryContainer : Color.clear, lineWidth: 2)
                                    )

                                    if member.isOnline {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 12, height: 12)
                                            .overlay(
                                                Circle()
                                                    .fill(AppTheme.primaryContainer)
                                                    .frame(width: 8, height: 8)
                                            )
                                    }
                                }
                                Text(member.name)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.PremiumDark)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    private func pollCard(_ poll: CommunityPoll) -> some View {
        let hasVoted = poll.selectedOptionId != nil

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "megaphone.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.tertiary)
                Text("Community Poll")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
            }

            Text(poll.question)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.PremiumDark)

            ForEach(poll.options) { option in
                Button(action: {
                    if !hasVoted {
                        viewModel.voteInPoll(optionId: option.id)
                    }
                }) {
                    ZStack(alignment: .leading) {
                        if hasVoted {
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppTheme.primaryContainer.opacity(0.12))
                                    .frame(width: geo.size.width * CGFloat(option.votesPercent / 100))
                            }
                        }

                        HStack {
                            Text(option.text)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.PremiumDark)
                            Spacer()
                            if hasVoted {
                                Text("\(Int(option.votesPercent))%")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.KineticGreen)
                            }
                        }
                        .padding(12)
                    }
                    .background(
                        option.id == poll.selectedOptionId
                            ? AppTheme.KineticGreen.opacity(0.08)
                            : AppTheme.SoftGray
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                option.id == poll.selectedOptionId
                                    ? AppTheme.primaryContainer
                                    : AppTheme.OutlineGray.opacity(0.4),
                                lineWidth: 2
                            )
                    )
                    .cornerRadius(8)
                }
                .disabled(hasVoted)
                .buttonStyle(PlainButtonStyle())
            }

            Text("\(poll.totalVotes) votes • \(poll.daysLeft) days left")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }

    private var groupChatPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.primary)
                    Text("Court 4 Chat")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                }
                Spacer()
                Text("3 NEW")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.ErrorRed)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(AppTheme.ErrorRed.opacity(0.12))
                    .cornerRadius(50)
            }

            ForEach(viewModel.messages.prefix(3)) { message in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.KineticGreen.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Text(String(message.senderName.prefix(1)).uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.KineticGreen)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(message.senderName)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                        Text(message.text)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(10)
                    .background(AppTheme.OutlineGray.opacity(0.35))
                    .cornerRadius(12, corners: [.topRight, .bottomLeft, .bottomRight])

                    Spacer(minLength: 0)
                }
            }

            Button(action: {}) {
                HStack(spacing: 4) {
                    Text("Join Conversation")
                        .font(.system(size: 14, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.primary)
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }

    private var topPlayersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Players")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.PremiumDark)

            ForEach(Array(viewModel.topPlayers.enumerated()), id: \.element.id) { index, player in
                Button(action: { onPlayerClick(player.id) }) {
                    topPlayerRow(player: player, rank: index + 1)
                }
                .buttonStyle(PlainButtonStyle())
            }

            Button(action: onLeaderboardClick) {
                Text("View Full Ranking")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.primary.opacity(0.4), lineWidth: 1)
                    )
            }
        }
    }

    private func topPlayerRow(player: CommunityMember, rank: Int) -> some View {
        let rankColor: Color = {
            switch rank {
            case 1: return AppTheme.accent
            case 2: return Color(red: 0.74, green: 0.74, blue: 0.74)
            case 3: return Color(red: 1, green: 0.8, blue: 0.5)
            default: return .gray
            }
        }()
        let rankTextColor: Color = {
            switch rank {
            case 2: return Color(red: 0.38, green: 0.38, blue: 0.38)
            case 3: return Color(red: 0.9, green: 0.32, blue: 0)
            default: return .white
            }
        }()
        let isGold = player.badge == "Gold"

        return HStack(spacing: 14) {
            ZStack(alignment: .topLeading) {
                ZStack {
                    Circle()
                        .fill(AppTheme.KineticGreen.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.KineticGreen)
                }
                Text("\(rank)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(rankTextColor)
                    .frame(width: 20, height: 20)
                    .background(rankColor)
                    .clipShape(Circle())
                    .offset(x: -4, y: -4)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                HStack(spacing: 6) {
                    Text(player.badge ?? "Member")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(isGold ? Color(red: 0.98, green: 0.66, blue: 0.15) : Color.gray)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isGold ? Color(red: 1, green: 0.98, blue: 0.77) : Color(red: 0.96, green: 0.96, blue: 0.96))
                        .cornerRadius(50)
                    Text(player.activity ?? "")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(player.points ?? 0)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                Text("PTS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.gray)
                    .kerning(0.6)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
