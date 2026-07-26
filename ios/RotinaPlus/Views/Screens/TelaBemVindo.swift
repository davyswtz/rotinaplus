import SwiftUI

// MARK: - Cores da tela
// Paleta usada no fundo, textos, botões e indicador de páginas.
private enum CoresBoasVindas {
    static let fundoSuperior = Color(red: 0.094, green: 0.078, blue: 0.059)
    static let fundoInferior = Color(red: 0.039, green: 0.031, blue: 0.024)
    static let roxoPrimario = Color(red: 0.910, green: 0.471, blue: 0.188)
    static let textoSecundario = Color.white.opacity(0.65)
    static let indicadorInativo = Color.white.opacity(0.25)
}

struct TelaBemVindo: View {
    /// Chamado ao concluir ou pular o welcome (vai para a próxima tela do onboarding).
    var onConcluido: () -> Void = {}

    /// Página 1 de 3 no fluxo de onboarding (índice 0).
    private let paginaAtual = 0
    private let totalPaginas = 3

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CoresBoasVindas.fundoSuperior, CoresBoasVindas.fundoInferior],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Image("splash_guara")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 184)
                    .padding(.bottom, 28)

                Text("Bem-vindo ao Rotina Plus!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("Transforme sua vida numa aventura RPG. Cada hábito completado te deixa mais forte, rico e sábio.")
                    .font(.body)
                    .foregroundStyle(CoresBoasVindas.textoSecundario)
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
                        .background(CoresBoasVindas.roxoPrimario)
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
                        .fill(CoresBoasVindas.roxoPrimario)
                        .frame(width: 24, height: 8)
                } else {
                    Circle()
                        .fill(CoresBoasVindas.indicadorInativo)
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}

#Preview {
    TelaBemVindo()
}
