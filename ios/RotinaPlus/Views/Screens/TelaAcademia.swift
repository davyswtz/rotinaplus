import SwiftUI

// MARK: - Modelos

struct DiaSemanaTreino: Identifiable, Equatable {
    let id: Int
    let label: String
    let foco: String
    var concluido: Bool
    let isRest: Bool
}

struct VolumeDia: Identifiable, Equatable {
    let id: String
    let label: String
    let kg: Double
}

// MARK: - Cores (Figma Academia)

private enum CoresAcademia {
    static let roxo = Color(red: 0.910, green: 0.471, blue: 0.188) // #E87830
    static let laranja = Color(red: 1.0, green: 0.608, blue: 0.290) // #FF9B4A
    static let verde = Color(red: 0.29, green: 0.87, blue: 0.50)
    static let card = Color(red: 0.10, green: 0.08, blue: 0.06).opacity(0.85)
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
    static let diaAtivoFundo = Color(red: 0.910, green: 0.471, blue: 0.188).opacity(0.28)
    static let diaAtivoBorda = Color(red: 0.910, green: 0.471, blue: 0.188).opacity(0.55)
}

// MARK: - Stats Academia (3 cards)

struct StatsAcademiaView: View {
    var metaSemana: Int = 0
    var feitos: Int
    var sequencia: Int = 0

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
    var onToggle: ((DiaSemanaTreino) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ESTA SEMANA")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(CoresAcademia.label)

            if dias.isEmpty {
                Text("Carregando dias da semana…")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CoresAcademia.labelMuted)
                    .padding(.vertical, 12)
            } else {
                HStack(spacing: 5) {
                    ForEach($dias) { $dia in
                        Button {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                dia.concluido.toggle()
                            }
                            onToggle?(dia)
                        } label: {
                            CapsulaDiaSemana(dia: dia)
                        }
                        .buttonStyle(.plain)
                    }
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
    var foco: String
    var exercicios: Int
    var minutos: Int
    var xp: Int
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
    var volumes: [VolumeDia] = []

    private var maxKg: Double {
        max(volumes.map(\.kg).max() ?? 1, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("VOLUME SEMANAL (KG)")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(CoresAcademia.label)

            if volumes.isEmpty {
                Text("O volume aparece aqui conforme você treina.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CoresAcademia.labelMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 20)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(volumes) { dia in
                        VStack(spacing: 8) {
                            if dia.kg > 0 {
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(CoresAcademia.roxo)
                                    .frame(height: CGFloat(dia.kg / maxKg) * 88)
                            } else {
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(Color.white.opacity(0.06))
                                    .frame(height: 8)
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

// MARK: - Empty treino CTA

private struct CardTreinoVazio: View {
    var onNovo: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Treino de hoje")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)

            Button(action: onNovo) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(CoresAcademia.laranja)
                        .frame(width: 50, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.black.opacity(0.28))
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Montar treino do dia")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Escolha o foco e comece a registrar")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.52))
                    }
                    Spacer(minLength: 2)
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
    @State private var dias: [DiaSemanaTreino] = []
    @State private var volumes: [VolumeDia] = []
    @State private var metaSemana = 0
    @State private var sequencia = 0
    @State private var treinoHoje: AcademiaTreinoAPI?
    @State private var esportes: [EsporteCatalogoAPI] = []
    @State private var esporteSessoes: [EsporteSessaoAPI] = []
    @State private var esporteResumo = EsporteResumoAPI(totalSemana: 0, minutosSemana: 0, xpSemana: 0)
    @State private var esporteSelecionado: EsporteCatalogoAPI?
    @State private var mostrarNovoTreino = false
    @State private var mostrarHistorico = false
    @State private var mostrarIniciar = false
    @State private var carregando = true
    @State private var erro: String?

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
                        Button {
                            mostrarHistorico = true
                            onHistorico()
                        } label: {
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

                    if carregando {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if let erro {
                        Text(erro)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, pad)
                            .padding(.top, gap)
                        Button("Tentar de novo") {
                            Task { await carregar() }
                        }
                        .foregroundStyle(CoresAcademia.roxo)
                        .padding(.horizontal, pad)
                        .padding(.top, 8)
                    } else {
                        StatsAcademiaView(metaSemana: metaSemana, feitos: feitos, sequencia: sequencia)
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        EstaSemanaTreinoView(dias: $dias, onToggle: { dia in
                            Task { await toggleDia(dia) }
                        })
                        .padding(.horizontal, pad)
                        .padding(.top, gap)

                        if let treino = treinoHoje {
                            CardTreinoHoje(
                                foco: treino.foco,
                                exercicios: treino.exercicios,
                                minutos: treino.minutos,
                                xp: treino.xp,
                                onIniciar: {
                                    mostrarIniciar = true
                                    onIniciarTreino()
                                },
                                onBiblioteca: {
                                    mostrarNovoTreino = true
                                    onBiblioteca()
                                }
                            )
                            .padding(.horizontal, pad)
                            .padding(.top, gap + 6)
                        } else {
                            CardTreinoVazio(onNovo: {
                                mostrarNovoTreino = true
                                onNovoTreino()
                            })
                                .padding(.horizontal, pad)
                                .padding(.top, gap + 6)
                        }

                        OutrosEsportesSection(
                            esportes: esportes,
                            resumo: esporteResumo,
                            sessoes: esporteSessoes,
                            onSelecionar: { esporteSelecionado = $0 },
                            onExcluir: { sessao in
                                Task { await excluirSessao(sessao) }
                            }
                        )
                        .padding(.horizontal, pad)
                        .padding(.top, gap)

                        VolumeSemanalChart(volumes: volumes)
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        AtalhosAcademiaView(
                            onNovo: {
                                mostrarNovoTreino = true
                                onNovoTreino()
                            },
                            onHistorico: {
                                mostrarHistorico = true
                                onHistorico()
                            }
                        )
                        .padding(.horizontal, pad)
                        .padding(.top, gap)
                        .padding(.bottom, 24)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .task { await carregar() }
        .fullScreenCover(isPresented: $mostrarNovoTreino) {
            TelaNovoTreino(
                treinoExistente: treinoHoje,
                onFechar: { mostrarNovoTreino = false },
                onSalvo: { Task { await carregar() } }
            )
        }
        .fullScreenCover(isPresented: $mostrarHistorico) {
            TelaHistoricoTreinos(onFechar: { mostrarHistorico = false })
        }
        .fullScreenCover(isPresented: $mostrarIniciar) {
            if let id = treinoHoje?.id {
                TelaIniciarTreino(
                    treinoId: id,
                    onFechar: { mostrarIniciar = false },
                    onConcluido: { Task { await carregar() } }
                )
            }
        }
        .sheet(item: $esporteSelecionado) { esporte in
            RegistrarEsporteSheet(esporte: esporte) { minutos, distancia, nota in
                esporteSelecionado = nil
                Task {
                    _ = try? await RotinaPlusAPI.registrarEsporte(
                        chave: esporte.chave,
                        minutos: minutos,
                        distanciaMetros: distancia,
                        nota: nota
                    )
                    await carregar()
                }
            } onCancelar: {
                esporteSelecionado = nil
            }
            .presentationDetents([.medium, .large])
        }
    }

    @MainActor
    private func carregar() async {
        carregando = true
        erro = nil
        do {
            let data = try await RotinaPlusAPI.academia()
            metaSemana = data.metaSemana
            sequencia = data.sequenciaTreinos
            dias = data.dias.map { $0.asDiaSemana() }
            volumes = data.volumes.map { $0.asVolume() }
            treinoHoje = data.treinoHoje
            esportes = data.esportes ?? []
            esporteSessoes = data.esporteSessoes ?? []
            esporteResumo = data.esporteResumo ?? EsporteResumoAPI(totalSemana: 0, minutosSemana: 0, xpSemana: 0)
        } catch {
            erro = error.localizedDescription
        }
        carregando = false
    }

    @MainActor
    private func toggleDia(_ dia: DiaSemanaTreino) async {
        do {
            try await RotinaPlusAPI.toggleAcademiaDia(id: dia.id, concluido: dia.concluido)
            sequencia = max(0, sequencia + (dia.concluido ? 1 : -1))
        } catch {
            if let i = dias.firstIndex(where: { $0.id == dia.id }) {
                dias[i].concluido.toggle()
            }
        }
    }

    @MainActor
    private func excluirSessao(_ sessao: EsporteSessaoAPI) async {
        try? await RotinaPlusAPI.excluirEsporteSessao(id: sessao.id)
        await carregar()
    }
}

// MARK: - Outros esportes

private struct OutrosEsportesSection: View {
    let esportes: [EsporteCatalogoAPI]
    let resumo: EsporteResumoAPI
    let sessoes: [EsporteSessaoAPI]
    var onSelecionar: (EsporteCatalogoAPI) -> Void
    var onExcluir: (EsporteSessaoAPI) -> Void

    private var linhas: [[EsporteCatalogoAPI]] {
        stride(from: 0, to: esportes.count, by: 3).map { inicio in
            Array(esportes[inicio..<min(inicio + 3, esportes.count)])
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("OUTROS ESPORTES")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(CoresAcademia.label)

            Text("Registre corrida, natação, vôlei e mais")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(CoresAcademia.labelMuted)

            HStack(spacing: 10) {
                miniStat(valor: "\(resumo.totalSemana)", label: "SESSÕES")
                miniStat(valor: "\(resumo.minutosSemana)m", label: "TEMPO")
                miniStat(valor: "+\(resumo.xpSemana)", label: "XP")
            }

            VStack(spacing: 10) {
                ForEach(Array(linhas.enumerated()), id: \.offset) { _, linha in
                    HStack(spacing: 10) {
                        ForEach(linha) { esporte in
                            Button {
                                onSelecionar(esporte)
                            } label: {
                                VStack(spacing: 8) {
                                    Text(esporte.icone)
                                        .font(.system(size: 26))
                                    Text(esporte.nome)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.white.opacity(0.04))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(CoresAcademia.bordaSuave, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        if linha.count < 3 {
                            ForEach(0..<(3 - linha.count), id: \.self) { _ in
                                Color.clear.frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }

            if !sessoes.isEmpty {
                Text("RECENTES")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(CoresAcademia.label)
                    .padding(.top, 4)

                VStack(spacing: 8) {
                    ForEach(sessoes.prefix(6)) { sessao in
                        HStack(spacing: 12) {
                            Text(sessao.icone).font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(sessao.nome)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text(subtitulo(sessao))
                                    .font(.caption)
                                    .foregroundStyle(CoresAcademia.label)
                            }
                            Spacer()
                            Text("+\(sessao.xp) XP")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(CoresAcademia.roxo)
                            Button {
                                onExcluir(sessao)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.35))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.03))
                        )
                    }
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

    private func miniStat(valor: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(valor)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(CoresAcademia.label)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
    }

    private func subtitulo(_ s: EsporteSessaoAPI) -> String {
        var parts = ["\(s.minutos) min"]
        if let m = s.distanciaMetros, m > 0 {
            let km = Double(m) / 1000.0
            parts.append(String(format: "%.1f km", km))
        }
        if let data = s.data { parts.append(data) }
        return parts.joined(separator: " · ")
    }
}

private struct RegistrarEsporteSheet: View {
    let esporte: EsporteCatalogoAPI
    var onSalvar: (Int, Int?, String?) -> Void
    var onCancelar: () -> Void

    @State private var minutosTexto = ""
    @State private var distanciaKm = ""
    @State private var nota = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("\(esporte.icone) \(esporte.nome)") {
                    Text(esporte.descricao)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("Minutos", text: $minutosTexto)
                        .keyboardType(.numberPad)
                    if esporte.usaDistancia {
                        TextField("Distância (km)", text: $distanciaKm)
                            .keyboardType(.decimalPad)
                    }
                    TextField("Nota (opcional)", text: $nota)
                }
            }
            .navigationTitle("Registrar sessão")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", action: onCancelar)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        let minutos = Int(minutosTexto) ?? esporte.minutosPadrao
                        var distancia: Int?
                        if esporte.usaDistancia,
                           let km = Double(distanciaKm.replacingOccurrences(of: ",", with: ".")) {
                            distancia = Int((km * 1000).rounded())
                        }
                        let n = nota.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSalvar(max(5, minutos), distancia, n.isEmpty ? nil : n)
                    }
                }
            }
            .onAppear {
                minutosTexto = "\(esporte.minutosPadrao)"
            }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.094, green: 0.078, blue: 0.059),
                Color(red: 0.039, green: 0.031, blue: 0.024),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        TelaAcademia()
    }
    .preferredColorScheme(.dark)
}
