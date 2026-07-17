import SwiftUI

struct WelcomeScreen: View {
    let onSignInClick: () -> Void
    let onCreateAccountClick: () -> Void

    var body: some View {
        ZStack {
            AppTheme.PremiumDark
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "figure.badminton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(AppTheme.KineticGreen)
                    .padding()
                    .background(AppTheme.KineticGreen.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(spacing: 8) {
                    Text("CourtSide")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.white)
                    
                    Text("Your Premium Badminton Community Hub")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: onSignInClick) {
                        Text("Sign In")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppTheme.KineticGreen)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onCreateAccountClick) {
                        Text("Create Account")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}
