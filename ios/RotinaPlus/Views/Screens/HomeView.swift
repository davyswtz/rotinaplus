import SwiftUI

/// Tela dashboard inicial — layout responsivo para todos os iPhones.
struct HomeView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var mostrarNotificacoes = false
    @State private var notificacoesNaoLidas = 0
    @State private var missoes: [MissaoDoDia] = []
    @State private var perfil: PerfilAPI?
    @State private var habitosResumo: HabitosResumoAPI?
    @State private var xpHojeAPI = 0
    @State private var abaSelecionada: AbaFooter = .inicio
    @State private var carregando = true
    @State private var erro: String?
    @State private var mostrarAdicionarMissao = false

    private var dadosHeader: DadosHeaderApp {
        let p = perfil
        let nomeLocal = UserDefaults.standard.string(forKey: "nome_heroi")?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let nome = p?.nomeExibicao
            ?? ((nomeLocal?.isEmpty == false) ? nomeLocal!.lowercased() : "herói")
        let avatar = p?.avatarAsset
            ?? UserDefaults.standard.string(forKey: "avatar_selecionado")
            ?? AvatarExplorador.guaraSerio.rawValue

        return DadosHeaderApp(
            nomeUsuario: nome,
            nivel: p?.nivel ?? 0,
            streakDias: p?.streakDias ?? 0,
            moedas: p?.moedas ?? 0,
            notificacoes: notificacoesNaoLidas,
            avatarAsset: avatar
        )
    }

    private var missoesConcluidas: Int {
        missoes.filter(\.concluida).count
    }

    private var xpHoje: Int {
        missoes.filter(\.concluida).reduce(0) { $0 + $1.xp }
    }

    var body: some View {
        GeometryReader { geo in
            let pad = LayoutDashboard.paddingHorizontal(geo.size.width)
            let gap = LayoutDashboard.gapSecao(geo.size.width)

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

                VStack(spacing: 0) {
                    HeaderApp(
                        dados: dadosHeader,
                        onToquePerfil: { abaSelecionada = .perfil },
                        onToqueNotificacoes: { mostrarNotificacoes = true }
                    )

                    Group {
                        switch abaSelecionada {
                        case .inicio:
                            conteudoInicio(pad: pad, gap: gap)
                        case .academia:
                            TelaAcademia()
                        case .financas:
                            TelaFinancas()
                        case .diario:
                            TelaDiarioHabitos { aba in
                                abaSelecionada = aba
                            }
                        case .estudos:
                            conteudoPlaceholder(
                                titulo: "Estudos",
                                descricao: "Esta área chega nas próximas etapas."
                            )
                        case .perfil:
                            TelaPerfil(
                                onPerfilAtualizado: { p in
                                    perfil = p
                                },
                                onSair: { authManager.logout() }
                            )
                        }
                    }

                    FooterNavegacao(abaSelecionada: $abaSelecionada)
                }
            }
        }
        .preferredColorScheme(.dark)
        .task { await carregarDashboard() }
        .fullScreenCover(isPresented: $mostrarNotificacoes) {
            TelaNotificacoes {
                mostrarNotificacoes = false
                Task { await carregarDashboard() }
            }
        }
        .sheet(isPresented: $mostrarAdicionarMissao) {
            AdicionarMissaoSheet(
                onSalvar: { titulo, detalhe, icone in
                    let criada = try await RotinaPlusAPI.criarMissao(
                        titulo: titulo,
                        detalhe: detalhe.isEmpty ? nil : detalhe,
                        icone: icone
                    )
                    await MainActor.run {
                        missoes.append(criada.asMissaoDoDia())
                        mostrarAdicionarMissao = false
                    }
                    await carregarDashboard()
                },
                onCancelar: { mostrarAdicionarMissao = false }
            )
            .presentationDetents([.medium, .large])
        }
    }

    private func conteudoInicio(pad: CGFloat, gap: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                if carregando && perfil == nil {
                    ProgressView()
                        .tint(.white)
                        .padding(.top, 40)
                } else if let erro, perfil == nil {
                    Text(erro)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, pad)
                        .padding(.top, gap)
                    Button("Tentar de novo") {
                        Task { await carregarDashboard() }
                    }
                    .foregroundStyle(Color(red: 0.910, green: 0.471, blue: 0.188))
                    .padding(.top, 8)
                } else {
                    CardPerfilHeroi(
                        dados: DadosCardPerfil(
                            nomeUsuario: dadosHeader.nomeUsuario,
                            classe: perfil?.classe ?? "",
                            emojiClasse: perfil?.emojiClasse ?? "",
                            nivel: dadosHeader.nivel,
                            xpAtual: perfil?.xpAtual ?? 0,
                            xpProximoNivel: perfil?.xpProximoNivel ?? 0,
                            avatarAsset: dadosHeader.avatarAsset
                        )
                    )
                    .padding(.horizontal, pad)
                    .padding(.top, gap)

                    GradeStatsDashboard(
                        dados: DadosGradeStats(
                            streakDias: max(dadosHeader.streakDias, habitosResumo?.streakGeral ?? 0),
                            habitosHojeConcluidos: habitosResumo?.concluidos ?? missoesConcluidas,
                            habitosHojeTotal: habitosResumo?.total ?? missoes.count,
                            xpHoje: xpHoje,
                            moedas: dadosHeader.moedas
                        )
                    )
                    .padding(.horizontal, pad)
                    .padding(.top, gap)

                    ProgressoDiarioCard(
                        dados: DadosProgressoDiario(
                            concluidos: habitosResumo?.concluidos ?? missoesConcluidas,
                            total: habitosResumo?.total ?? missoes.count
                        )
                    )
                    .padding(.horizontal, pad)
                    .padding(.top, gap)

                    MissoesDoDiaView(
                        missoes: $missoes,
                        onToggle: { missao in
                            Task { await toggleMissao(missao) }
                        },
                        onAdicionar: { mostrarAdicionarMissao = true }
                    )
                    .padding(.horizontal, pad)
                    .padding(.top, gap + 4)

                    AtalhosRapidosView { atalho in
                        if let aba = atalho.abaDestino {
                            abaSelecionada = aba
                        }
                    }
                    .padding(.horizontal, pad)
                    .padding(.top, gap + 4)
                    .padding(.bottom, 24)
                }
            }
        }
        .refreshable { await carregarDashboard() }
    }

    private func conteudoPlaceholder(
        titulo: String,
        descricao: String,
        @ViewBuilder extra: () -> some View = { EmptyView() }
    ) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Text(titulo)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(descricao)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            extra()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    @MainActor
    private func carregarDashboard() async {
        // Abre com cache local imediatamente (modo offline).
        if let cached = OfflineStore.shared.load(DashboardAPI.self, key: .dashboard) {
            perfil = cached.perfil
            missoes = cached.missoes.map { $0.asMissaoDoDia() }
            notificacoesNaoLidas = cached.notificacoesNaoLidas
            xpHojeAPI = cached.xpHoje
            habitosResumo = cached.habitosResumo
            carregando = false
        } else {
            carregando = true
        }
        erro = nil
        do {
            let data = try await RotinaPlusAPI.dashboard()
            perfil = data.perfil
            missoes = data.missoes.map { $0.asMissaoDoDia() }
            notificacoesNaoLidas = data.notificacoesNaoLidas
            xpHojeAPI = data.xpHoje
            habitosResumo = data.habitosResumo

            if let nome = data.perfil.nomeHeroi, !nome.isEmpty {
                UserDefaults.standard.set(nome, forKey: "nome_heroi")
            }
            UserDefaults.standard.set(data.perfil.avatarAsset, forKey: "avatar_selecionado")
            await OfflineSyncEngine.shared.flush()
            await LembretesService.shared.reagendarTudo()
        } catch {
            if perfil == nil {
                erro = error.localizedDescription
            }
        }
        carregando = false
    }

    @MainActor
    private func toggleMissao(_ missao: MissaoDoDia) async {
        // UI já alternou localmente em MissoesDoDiaView
        do {
            _ = try await RotinaPlusAPI.toggleMissao(id: missao.id, concluida: missao.concluida)
            // Atualiza XP/nível do perfil
            let data = try await RotinaPlusAPI.dashboard()
            perfil = data.perfil
            notificacoesNaoLidas = data.notificacoesNaoLidas
            habitosResumo = data.habitosResumo
        } catch {
            if let i = missoes.firstIndex(where: { $0.id == missao.id }) {
                missoes[i].concluida.toggle()
            }
        }
    }
}

#Preview {
    HomeView()
}
