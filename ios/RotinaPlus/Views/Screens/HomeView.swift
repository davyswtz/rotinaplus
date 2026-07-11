import SwiftUI

struct HomeView: View {
    @ObservedObject private var authManager = AuthManager.shared

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.06, blue: 0.18),
                    Color(red: 0.05, green: 0.03, blue: 0.10),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("RotinaPlus")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Login realizado com sucesso.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))

                Button("Sair") {
                    authManager.logout()
                }
                .fontWeight(.semibold)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(red: 0.48, green: 0.26, blue: 0.96))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    HomeView()
}
