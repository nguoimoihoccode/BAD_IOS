import SwiftUI

struct OnboardingSlide {
    let title: String
    let description: String
    let iconName: String
}

struct OnboardingScreen: View {
    var onGetStarted: () -> Void
    
    @State private var currentPage = 0
    
    private let slides = [
        OnboardingSlide(
            title: "Book Courts & Sessions",
            description: "Easily join scheduled badminton court sessions, split fees fairly, and manage court schedules.",
            iconName: "sportscourt.fill"
        ),
        OnboardingSlide(
            title: "Matchmaking Challenges",
            description: "Challenge other club members, record your set scores, and climb the ranks.",
            iconName: "trophy.fill"
        ),
        OnboardingSlide(
            title: "Community & Ratings",
            description: "Participate in active polls, chat with players, and build your badminton circle.",
            iconName: "person.3.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            // Dark Gradient Background
            LinearGradient(
                colors: [Color(hex: "022C22"), Color(hex: "064E3B"), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Skip Button
                HStack {
                    Spacer()
                    Button(action: onGetStarted) {
                        Text("Skip")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppTheme.OnSurfaceVariant)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                }
                
                // Paging Slides
                TabView(selection: $currentPage) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        let slide = slides[index]
                        VStack(spacing: 24) {
                            // Animated Icon Container
                            ZStack {
                                Circle()
                                    .fill(AppTheme.KineticGreen.opacity(0.15))
                                    .frame(width: 140, height: 140)
                                
                                Image(systemName: slide.iconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(AppTheme.KineticGreen)
                            }
                            .scaleEffect(currentPage == index ? 1.0 : 0.8)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: currentPage)
                            
                            // Text Contents
                            Text(slide.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(slide.description)
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.OnSurfaceVariant)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .lineSpacing(4)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Indicators & Next Button Row
                HStack {
                    // Custom dot indicator
                    HStack(spacing: 8) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? AppTheme.KineticGreen : Color.white.opacity(0.3))
                                .frame(width: currentPage == index ? 24 : 8, height: 8)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    Spacer()
                    
                    // Action Button
                    Button(action: {
                        if currentPage < slides.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            onGetStarted()
                        }
                    }) {
                        Text(currentPage == slides.count - 1 ? "Get Started" : "Next")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(AppTheme.KineticGreen)
                            .cornerRadius(24)
                            .shadow(color: AppTheme.KineticGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}
