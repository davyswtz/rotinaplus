import SwiftUI

struct DadosGradeStats: Equatable {
    var streakDias: Int
    var habitosHojeConcluidos: Int
    var habitosHojeTotal: Int
    var xpHoje: Int
    var moedas: Int

    static let preview = DadosGradeStats(
        streakDias: 3,
        habitosHojeConcluidos: 2,
        habitosHojeTotal: 5,
        xpHoje: 60,
        moedas: 480
    )
}

/// Grade 4 stats abaixo do card de perfil (2×2, altura intrínseca).
struct GradeStatsDashboard: View {
    let dados: DadosGradeStats

    private var itens: [(icone: String, cor: Color, valor: String, label: String)] {
        [
            ("flame", CoresGradeStats.streak, "\(dados.streakDias)d", "STREAK"),
            (
                "checkmark.circle.fill",
                CoresGradeStats.hoje,
                "\(dados.habitosHojeConcluidos)/\(dados.habitosHojeTotal)",
                "HOJE"
            ),
            ("star", CoresGradeStats.xp, "+\(dados.xpHoje)", "XP HOJE"),
            ("crown", CoresGradeStats.moedas, "\(dados.moedas)", "MOEDAS"),
        ]
    }

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
            ],
            spacing: 8
        ) {
            ForEach(Array(itens.enumerated()), id: \.offset) { _, item in
                card(
                    icone: item.icone,
                    cor: item.cor,
                    valor: item.valor,
                    label: item.label
                )
            }
        }
    }

    private func card(icone: String, cor: Color, valor: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icone)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(cor)

            Text(valor)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.4)
                .foregroundStyle(CoresGradeStats.label)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background(RoundedRectangle(cornerRadius: 16).fill(CoresGradeStats.card))
    }
}

private enum CoresGradeStats {
    static let card = Color.white.opacity(0.05)
    static let label = Color.white.opacity(0.40)
    static let streak = Color(red: 1.0, green: 0.55, blue: 0.28)
    static let hoje = Color(red: 0.30, green: 0.85, blue: 0.45)
    static let xp = Color(red: 0.941, green: 0.659, blue: 0.349)
    static let moedas = Color(red: 1.0, green: 0.82, blue: 0.28)
}

#Preview {
    ZStack {
        Color(red: 0.039, green: 0.031, blue: 0.024).ignoresSafeArea()
        GradeStatsDashboard(dados: .preview)
            .padding()
    }
    .preferredColorScheme(.dark)
}
