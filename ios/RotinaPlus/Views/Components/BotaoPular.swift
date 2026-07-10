import SwiftUI

/// Componente do botão **Pular** das telas de onboarding e boas-vindas.
/// Texto discreto na parte inferior; permite ignorar o fluxo introdutório.
struct BotaoPular: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Pular")
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.55))
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ZStack {
        Color(red: 0.07, green: 0.04, blue: 0.13)
            .ignoresSafeArea()
        BotaoPular(action: {})
    }
}
