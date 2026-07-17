import SwiftUI

struct LoginScreen: View {
    let onBackClick: () -> Void
    let onLoginSuccess: () -> Void
    @ObservedObject var viewModel: AuthViewModel

    @State private var email = "player@test.com"
    @State private var password = "password"

    var body: some View {
        ZStack {
            AppTheme.PremiumDark
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: onBackClick) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome Back")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Sign in to join scheduled badminton events.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 20)
                
                // Form Fields
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(AppTheme.ErrorRed)
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Submit Button
                Button(action: {
                    viewModel.login(email: email, password: password, onSuccess: onLoginSuccess)
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign In")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppTheme.KineticGreen)
                    .cornerRadius(8)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
