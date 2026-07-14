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

/// Grade 4 stats abaixo do card de perfil.
struct GradeStatsDashboard: View {
    let dados: DadosGradeStats

    var body: some View {
        GeometryReader { geo in
            let compacto = LayoutDashboard.isCompacto(geo.size.width)
            let gap: CGFloat = compacto ? 8 : 10

            if compacto {
                VStack(spacing: gap) {
                    HStack(spacing: gap) {
                        card(icone: "flame", cor: CoresGradeStats.streak, valor: "\(dados.streakDias)d", label: "STREAK", compacto: true)
                        card(icone: "checkmark.circle.fill", cor: CoresGradeStats.hoje, valor: "\(dados.habitosHojeConcluidos)/\(dados.habitosHojeTotal)", label: "HOJE", compacto: true)
                    }
                    HStack(spacing: gap) {
                        card(icone: "star", cor: CoresGradeStats.xp, valor: "+\(dados.xpHoje)", label: "XP HOJE", compacto: true)
                        card(icone: "crown", cor: CoresGradeStats.moedas, valor: "\(dados.moedas)", label: "MOEDAS", compacto: true)
                    }
                }
            } else {
                HStack(spacing: gap) {
                    card(icone: "flame", cor: CoresGradeStats.streak, valor: "\(dados.streakDias)d", label: "STREAK", compacto: false)
                    card(icone: "checkmark.circle.fill", cor: CoresGradeStats.hoje, valor: "\(dados.habitosHojeConcluidos)/\(dados.habitosHojeTotal)", label: "HOJE", compacto: false)
                    card(icone: "star", cor: CoresGradeStats.xp, valor: "+\(dados.xpHoje)", label: "XP HOJE", compacto: false)
                    card(icone: "crown", cor: CoresGradeStats.moedas, valor: "\(dados.moedas)", label: "MOEDAS", compacto: false)
                }
            }
        }
        .frame(height: LayoutDashboard.isCompacto(UIScreen.main.bounds.width) ? 168 : 96)
    }

    private func card(icone: String, cor: Color, valor: String, label: String, compacto: Bool) -> some View {
        VStack(spacing: compacto ? 6 : 8) {
            Image(systemName: icone)
                .font(.system(size: compacto ? 16 : 18, weight: .semibold))
                .foregroundStyle(cor)

            Text(valor)
                .font(.system(size: compacto ? 15 : 16, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            Text(label)
                .font(.system(size: compacto ? 9 : 10, weight: .semibold))
                .tracking(0.4)
                .foregroundStyle(CoresGradeStats.label)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, compacto ? 12 : 14)
        .padding(.horizontal, 4)
        .background(RoundedRectangle(cornerRadius: 16).fill(CoresGradeStats.card))
    }
}

private enum CoresGradeStats {
    static let card = Color.white.opacity(0.05)
    static let label = Color.white.opacity(0.40)
    static let streak = Color(red: 1.0, green: 0.55, blue: 0.28)
    static let hoje = Color(red: 0.30, green: 0.85, blue: 0.45)
    static let xp = Color(red: 0.62, green: 0.42, blue: 0.98)
    static let moedas = Color(red: 1.0, green: 0.82, blue: 0.28)
}

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.03, blue: 0.10).ignoresSafeArea()
        GradeStatsDashboard(dados: .preview)
            .padding()
    }
    .preferredColorScheme(.dark)
}
