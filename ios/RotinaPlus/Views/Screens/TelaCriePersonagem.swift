import SwiftUI

// MARK: - Cores (mesma paleta do welcome / login)
private enum CoresCriePersonagem {
    static let fundoSuperior = Color(red: 0.10, green: 0.06, blue: 0.18)
    static let fundoInferior = Color(red: 0.05, green: 0.03, blue: 0.10)
    static let roxoPrimario = Color(red: 0.48, green: 0.26, blue: 0.96)
    static let textoSecundario = Color.white.opacity(0.65)
    static let indicadorInativo = Color.white.opacity(0.25)
    static let laranjaMascote = Color(red: 1.0, green: 0.55, blue: 0.20)
}

/// Segunda etapa do onboarding — aparece depois de `TelaBemVindo`.
struct TelaCriePersonagem: View {
    var onConcluido: () -> Void = {}

    /// Página 2 de 3 no fluxo de onboarding (índice 1).
    private let paginaAtual = 1
    private let totalPaginas = 3

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CoresCriePersonagem.fundoSuperior, CoresCriePersonagem.fundoInferior],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Image(systemName: "pawprint.fill")
                    .font(.system(size: 88))
                    .foregroundStyle(CoresCriePersonagem.laranjaMascote)
                    .padding(.bottom, 40)

                Text("Crie seu personagem único")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("Escolha sua classe, avatar e nome. Seu herói evolui conforme você avança na vida real.")
                    .font(.body)
                    .foregroundStyle(CoresCriePersonagem.textoSecundario)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 16)

                Spacer()

                indicadorPaginas
                    .padding(.bottom, 28)

                Button {
                    onConcluido()
                } label: {
                    Text("Próximo →")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(CoresCriePersonagem.roxoPrimario)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)

                BotaoPular {
                    onConcluido()
                }
                .padding(.bottom, 16)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var indicadorPaginas: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPaginas, id: \.self) { indice in
                if indice == paginaAtual {
                    Capsule()
                        .fill(CoresCriePersonagem.roxoPrimario)
                        .frame(width: 24, height: 8)
                } else {
                    Circle()
                        .fill(CoresCriePersonagem.indicadorInativo)
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}

#Preview {
    TelaCriePersonagem()
}
