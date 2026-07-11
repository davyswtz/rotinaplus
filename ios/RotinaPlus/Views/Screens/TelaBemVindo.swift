import SwiftUI

// MARK: - Cores da tela
// Paleta usada no fundo, textos, botões e indicador de páginas.
private enum CoresBoasVindas {
    static let fundoSuperior = Color(red: 0.10, green: 0.06, blue: 0.18)
    static let fundoInferior = Color(red: 0.05, green: 0.03, blue: 0.10)
    static let roxoPrimario = Color(red: 0.48, green: 0.26, blue: 0.96)
    static let textoSecundario = Color.white.opacity(0.65)
    static let indicadorInativo = Color.white.opacity(0.25)
}

struct TelaBemVindo: View {

    // MARK: - Estado da tela
    @State private var paginaAtual = 0      // página ativa no onboarding (0, 1 ou 2)

    private let totalPaginas = 3

    var body: some View {
        ZStack {

                // MARK: Fundo
                // Gradiente roxo escuro que cobre a tela inteira.
                LinearGradient(
                    colors: [CoresBoasVindas.fundoSuperior, CoresBoasVindas.fundoInferior],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // MARK: Conteúdo principal
                // VStack vertical: topo (mascote + textos) → base (indicador + botões).
                VStack(spacing: 0) {
                    Spacer()

                    // MARK: Mascote
                    // Ícone/imagem do guará no centro-superior da tela.
                    // TODO: substituir por Image("guara") quando o asset estiver no projeto.
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 88))
                        .foregroundStyle(Color(red: 1.0, green: 0.55, blue: 0.20))
                        .padding(.bottom, 40)

                    // MARK: Título
                    // Texto principal em branco: "Bem-vindo ao Rotina Plus!"
                    Text("Bem-vindo ao Rotina Plus!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    // MARK: Descrição
                    // Subtítulo cinza com o texto sobre RPG e hábitos.
                    Text("Transforme sua vida numa aventura RPG. Cada hábito completado te deixa mais forte, rico e sábio.")
                        .font(.body)
                        .foregroundStyle(CoresBoasVindas.textoSecundario)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 16)

                    Spacer()

                    // MARK: Indicador de páginas
                    // Bolinhas/cápsula roxa acima do botão "Próximo".
                    indicadorPaginas
                        .padding(.bottom, 28)

                    // MARK: Botão "Próximo"
                    // Botão roxo grande que avança o onboarding.
                    Button {
                        avancar()
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

                    // MARK: Botão "Pular"
                    // Componente reutilizável (BotaoPular.swift) — texto discreto no rodapé.
                    BotaoPular {
                        avancar()
                    }
                    .padding(.bottom, 16)
                }
            }
        .preferredColorScheme(.dark)
    }

    // MARK: Indicador de páginas (componente interno)
    // Página ativa = cápsula roxa; demais = círculos cinza.
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

    // MARK: Ação do botão "Próximo"
    // Avança para a próxima página do onboarding.
    private func avancar() {
        if paginaAtual < totalPaginas - 1 {
            paginaAtual += 1
        }
    }
}

#Preview {
    TelaBemVindo()
}
