import SwiftUI

struct MissaoDoDia: Identifiable, Equatable {
    let id: UUID
    var icone: String
    var titulo: String
    var detalhe: String
    var xp: Int
    var concluida: Bool

    init(
        id: UUID = UUID(),
        icone: String,
        titulo: String,
        detalhe: String,
        xp: Int,
        concluida: Bool
    ) {
        self.id = id
        self.icone = icone
        self.titulo = titulo
        self.detalhe = detalhe
        self.xp = xp
        self.concluida = concluida
    }

    static let exemplos: [MissaoDoDia] = [
        .init(icone: "💧", titulo: "Beber água", detalhe: "2L ao longo do dia", xp: 15, concluida: true),
        .init(icone: "🏃", titulo: "Treinar", detalhe: "30 min de movimento", xp: 25, concluida: true),
        .init(icone: "📚", titulo: "Estudar", detalhe: "1 Pomodoro focado", xp: 20, concluida: false),
        .init(icone: "🧘", titulo: "Meditar", detalhe: "10 min de respiração", xp: 15, concluida: false),
        .init(icone: "💰", titulo: "Registrar gastos", detalhe: "Anotar o dia no app", xp: 10, concluida: false),
    ]
}

private enum CoresMissoes {
    static let tituloSecao = Color.white.opacity(0.55)
    static let card = Color.white.opacity(0.05)
    static let borda = Color.white.opacity(0.08)
    static let detalhe = Color.white.opacity(0.45)
    static let xp = Color(red: 0.62, green: 0.42, blue: 0.98)
    static let xpVerde = Color(red: 0.29, green: 0.87, blue: 0.50)
    static let check = Color(red: 0.29, green: 0.87, blue: 0.50)
    static let pendente = Color.white.opacity(0.22)
    /// Fundo escuro esverdeado da missão concluída.
    static let cardConcluida = Color(red: 0.06, green: 0.12, blue: 0.09)
    static let bordaConcluida = Color(red: 0.29, green: 0.87, blue: 0.50)
    static let tituloConcluido = Color.white.opacity(0.45)
    static let detalheConcluido = Color.white.opacity(0.28)
}

/// Lista de missões do dia (abaixo do progresso diário).
struct MissoesDoDiaView: View {
    @Binding var missoes: [MissaoDoDia]
    var onToggle: ((MissaoDoDia) -> Void)?

    private var concluidas: Int {
        missoes.filter(\.concluida).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("MISSÕES DO DIA")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(CoresMissoes.tituloSecao)

                Spacer()

                Text("\(concluidas)/\(missoes.count)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(CoresMissoes.xp)
            }

            VStack(spacing: 10) {
                ForEach(missoes) { missao in
                    botaoMissao(missao)
                }
            }
        }
    }

    private func botaoMissao(_ missao: MissaoDoDia) -> some View {
        Button {
            toggle(missao.id)
            onToggle?(missao)
        } label: {
            HStack(spacing: 10) {
                Text(missao.icone)
                    .font(.system(size: 20))
                    .frame(width: 34, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                missao.concluida
                                    ? CoresMissoes.check.opacity(0.12)
                                    : Color.white.opacity(0.06)
                            )
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(missao.titulo)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(
                            missao.concluida ? CoresMissoes.tituloConcluido : .white
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .strikethrough(missao.concluida, color: CoresMissoes.tituloConcluido)

                    Text(missao.detalhe)
                        .font(.system(size: 12))
                        .foregroundStyle(
                            missao.concluida ? CoresMissoes.detalheConcluido : CoresMissoes.detalhe
                        )
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("+\(missao.xp)xp")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(CoresMissoes.xpVerde)
                    .lineLimit(1)
                    .layoutPriority(1)

                Image(systemName: missao.concluida ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(missao.concluida ? CoresMissoes.check : CoresMissoes.pendente)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(missao.concluida ? CoresMissoes.cardConcluida : CoresMissoes.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        missao.concluida ? CoresMissoes.bordaConcluida : CoresMissoes.borda,
                        lineWidth: missao.concluida ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func toggle(_ id: UUID) {
        guard let indice = missoes.firstIndex(where: { $0.id == id }) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            missoes[indice].concluida.toggle()
        }
    }
}

#Preview {
    struct PreviewHost: View {
        @State private var missoes = MissaoDoDia.exemplos
        var body: some View {
            ZStack {
                Color(red: 0.05, green: 0.03, blue: 0.10).ignoresSafeArea()
                ScrollView {
                    MissoesDoDiaView(missoes: $missoes)
                        .padding()
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    return PreviewHost()
}
