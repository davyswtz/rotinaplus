import SwiftUI

// MARK: - Modelos

struct DiaSemanaTreino: Identifiable, Equatable {
    let id: String
    let label: String
    let foco: String
    var concluido: Bool
    let isRest: Bool

    static let semanaExemplo: [DiaSemanaTreino] = [
        .init(id: "seg", label: "Seg", foco: "Peito", concluido: true, isRest: false),
        .init(id: "ter", label: "Ter", foco: "Costas", concluido: true, isRest: false),
        .init(id: "qua", label: "Qua", foco: "Ombros", concluido: false, isRest: false),
        .init(id: "qui", label: "Qui", foco: "Braços", concluido: false, isRest: false),
        .init(id: "sex", label: "Sex", foco: "Pernas", concluido: false, isRest: false),
        .init(id: "sab", label: "Sáb", foco: "Cardio", concluido: false, isRest: false),
        .init(id: "dom", label: "Dom", foco: "Rest", concluido: false, isRest: true),
    ]
}

struct VolumeDia: Identifiable, Equatable {
    let id: String
    let label: String
    let kg: Double
}

// MARK: - Cores (Figma Academia)

private enum CoresAcademia {
    static let roxo = Color(red: 0.478, green: 0.259, blue: 0.961) // #7A42F5
    static let laranja = Color(red: 1.0, green: 0.549, blue: 0.200) // #FF8C33
    static let verde = Color(red: 0.29, green: 0.87, blue: 0.50)
    static let card = Color(red: 0.10, green: 0.08, blue: 0.16).opacity(0.85)
    static let cardElevado = Color.white.opacity(0.055)
    static let borda = Color.white.opacity(0.10)
    static let bordaSuave = Color.white.opacity(0.07)
    static let label = Color.white.opacity(0.42)
    static let labelMuted = Color.white.opacity(0.32)
    static let historicoFundo = Color(red: 0.30, green: 0.12, blue: 0.10)
    static let ctaTop = Color(red: 0.42, green: 0.14, blue: 0.12)
    static let ctaMid = Color(red: 0.28, green: 0.09, blue: 0.10)
    static let ctaBot = Color(red: 0.14, green: 0.05, blue: 0.08)
    static let diaInativoBorda = Color.white.opacity(0.12)
    static let diaAtivoFundo = Color(red: 0.48, green: 0.26, blue: 0.96).opacity(0.28)
    static let diaAtivoBorda = Color(red: 0.48, green: 0.26, blue: 0.96).opacity(0.55)
}

// MARK: - Stats Academia (3 cards)

struct StatsAcademiaView: View {
    var metaSemana: Int = 5
    var feitos: Int
    var sequencia: Int = 12

    var body: some View {
        HStack(spacing: 10) {
            card(icone: "dumbbell.fill", cor: CoresAcademia.laranja, valor: "\(metaSemana)x", label: "META/SEM")
            card(icone: "checkmark.circle.fill", cor: CoresAcademia.verde, valor: "\(feitos)/\(metaSemana)", label: "FEITOS")
            card(icone: "flame.fill", cor: CoresAcademia.roxo, valor: "\(sequencia)", label: "SEQ. TREINOS")
        }
    }

    private func card(icone: String, cor: Color, valor: String, label: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icone)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(cor)
            Text(valor)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(CoresAcademia.label)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(CoresAcademia.cardElevado)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(CoresAcademia.bordaSuave, lineWidth: 1)
        )
    }
}

// MARK: - Esta Semana (clicável)

struct EstaSemanaTreinoView: View {
    @Binding var dias: [DiaSemanaTreino]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ESTA SEMANA")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(CoresAcademia.label)

            HStack(spacing: 5) {
                ForEach($dias) { $dia in
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            dia.concluido.toggle()
                        }
                    } label: {
                        CapsulaDiaSemana(dia: dia)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(CoresAcademia.cardElevado)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(CoresAcademia.bordaSuave, lineWidth: 1)
        )
    }
}

private struct CapsulaDiaSemana: View {
    let dia: DiaSemanaTreino

    var body: some View {
        VStack(spacing: 8) {
            Text(dia.label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(dia.concluido ? .white : CoresAcademia.labelMuted)

            ZStack {
                if dia.concluido {
                    Circle()
                        .fill(CoresAcademia.roxo)
                        .frame(width: 32, height: 32)
                        .shadow(color: CoresAcademia.roxo.opacity(0.45), radius: 6, y: 2)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 32, height: 32)
                    Image(systemName: dia.isRest ? "moon.fill" : "dumbbell.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.28))
                }
            }

            Text(dia.foco)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(dia.concluido ? Color.white.opacity(0.75) : CoresAcademia.labelMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 2)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(dia.concluido ? CoresAcademia.diaAtivoFundo : Color.white.opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    dia.concluido ? CoresAcademia.diaAtivoBorda : CoresAcademia.diaInativoBorda,
                    lineWidth: 1
                )
        )
    }
}

// MARK: - CTA Treino de hoje

struct CardTreinoHoje: View {
    var foco: String = "Ombros"
    var exercicios: Int = 8
    var minutos: Int = 45
    var xp: Int = 140
    var onIniciar: () -> Void = {}
    var onBiblioteca: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Treino de hoje — \(foco)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 8)
                Button("Biblioteca", action: onBiblioteca)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CoresAcademia.roxo)
            }

            Button(action: onIniciar) {
                HStack(spacing: 12) {
                    Text("🔥")
                        .font(.system(size: 24))
                        .frame(width: 50, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.black.opacity(0.28))
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Iniciar treino de \(foco)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                        Text("\(exercicios) exercícios · ~\(minutos) min · +\(xp) XP")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.52))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }

                    Spacer(minLength: 2)

                    Image(systemName: "play.circle")
                        .font(.system(size: 36, weight: .regular))
                        .foregroundStyle(CoresAcademia.laranja)
                }
                .padding(14)
                .background(
                    LinearGradient(
                        colors: [CoresAcademia.ctaTop, CoresAcademia.ctaMid, CoresAcademia.ctaBot],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Volume Semanal

struct VolumeSemanalChart: View {
    var volumes: [VolumeDia] = [
        .init(id: "seg", label: "Seg", kg: 4200),
        .init(id: "ter", label: "Ter", kg: 3100),
        .init(id: "qua", label: "Qua", kg: 0),
        .init(id: "qui", label: "Qui", kg: 0),
        .init(id: "sex", label: "Sex", kg: 0),
        .init(id: "sab", label: "Sáb", kg: 0),
        .init(id: "dom", label: "Dom", kg: 0),
    ]

    private var maxKg: Double {
        max(volumes.map(\.kg).max() ?? 1, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("VOLUME SEMANAL (KG)")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(CoresAcademia.label)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(volumes) { dia in
                    VStack(spacing: 8) {
                        if dia.kg > 0 {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(CoresAcademia.roxo)
                                .frame(height: CGFloat(dia.kg / maxKg) * 88)
                        } else {
                            Spacer(minLength: 0)
                        }
                        Text(dia.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(CoresAcademia.labelMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 110, alignment: .bottom)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(CoresAcademia.cardElevado)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(CoresAcademia.bordaSuave, lineWidth: 1)
        )
    }
}

// MARK: - Atalhos Academia

struct AtalhosAcademiaView: View {
    var onNovo: () -> Void = {}
    var onHistorico: () -> Void = {}

    var body: some View {
        HStack(spacing: 10) {
            atalho(titulo: "Novo treino", icone: "plus", cor: CoresAcademia.roxo, action: onNovo)
            atalho(titulo: "Histórico", icone: "list.bullet", cor: CoresAcademia.laranja, action: onHistorico)
        }
    }

    private func atalho(titulo: String, icone: String, cor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icone)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(cor)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(cor.opacity(0.18)))
                Text(titulo)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(CoresAcademia.cardElevado)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(CoresAcademia.bordaSuave, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tela Academia

struct TelaAcademia: View {
    @State private var dias = DiaSemanaTreino.semanaExemplo

    var onHistorico: () -> Void = {}
    var onBiblioteca: () -> Void = {}
    var onIniciarTreino: () -> Void = {}
    var onNovoTreino: () -> Void = {}

    private var feitos: Int {
        dias.filter(\.concluido).count
    }

    var body: some View {
        GeometryReader { geo in
            let pad = LayoutDashboard.paddingHorizontal(geo.size.width)
            let gap = LayoutDashboard.gapSecao(geo.size.width)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Academia")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                        Button(action: onHistorico) {
                            Text("Histórico")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(CoresAcademia.laranja)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(CoresAcademia.historicoFundo))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, pad)
                    .padding(.top, gap)

                    StatsAcademiaView(feitos: feitos)
                        .padding(.horizontal, pad)
                        .padding(.top, gap)

                    EstaSemanaTreinoView(dias: $dias)
                        .padding(.horizontal, pad)
                        .padding(.top, gap)

                    CardTreinoHoje(
                        onIniciar: onIniciarTreino,
                        onBiblioteca: onBiblioteca
                    )
                    .padding(.horizontal, pad)
                    .padding(.top, gap + 6)

                    VolumeSemanalChart()
                        .padding(.horizontal, pad)
                        .padding(.top, gap)

                    AtalhosAcademiaView(
                        onNovo: onNovoTreino,
                        onHistorico: onHistorico
                    )
                    .padding(.horizontal, pad)
                    .padding(.top, gap)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

#Preview {
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
        TelaAcademia()
    }
    .preferredColorScheme(.dark)
}
