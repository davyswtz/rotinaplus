import SwiftUI

/// Tela dashboard inicial — layout responsivo para todos os iPhones.
struct HomeView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var mostrarNotificacoes = false
    @State private var notificacoesNaoLidas = 0
    @State private var missoes: [MissaoDoDia] = []
    @State private var perfil: PerfilAPI?
    @State private var xpHojeAPI = 0
    @State private var abaSelecionada: AbaFooter = .inicio
    @State private var carregando = true
    @State private var erro: String?

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
            nivel: p?.nivel ?? 1,
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
                        Color(red: 0.10, green: 0.06, blue: 0.18),
                        Color(red: 0.05, green: 0.03, blue: 0.10),
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
                        case .perfil:
                            conteudoPlaceholder(
                                titulo: "Perfil",
                                descricao: "Em breve: editar herói, classe e preferências."
                            ) {
                                Button("Sair") { authManager.logout() }
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color(red: 0.48, green: 0.26, blue: 0.96))
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.top, 16)
                            }
                        default:
                            conteudoPlaceholder(
                                titulo: abaSelecionada.titulo,
                                descricao: "Esta área chega nas próximas etapas."
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
                    .foregroundStyle(Color(red: 0.48, green: 0.26, blue: 0.96))
                    .padding(.top, 8)
                } else {
                    CardPerfilHeroi(
                        dados: DadosCardPerfil(
                            nomeUsuario: dadosHeader.nomeUsuario,
                            classe: perfil?.classe ?? "Sábio",
                            emojiClasse: perfil?.emojiClasse ?? "🔮",
                            nivel: dadosHeader.nivel,
                            xpAtual: perfil?.xpAtual ?? 0,
                            xpProximoNivel: perfil?.xpProximoNivel ?? 500,
                            avatarAsset: dadosHeader.avatarAsset
                        )
                    )
                    .padding(.horizontal, pad)
                    .padding(.top, gap)

                    GradeStatsDashboard(
                        dados: DadosGradeStats(
                            streakDias: dadosHeader.streakDias,
                            habitosHojeConcluidos: missoesConcluidas,
                            habitosHojeTotal: max(missoes.count, 1),
                            xpHoje: xpHoje,
                            moedas: dadosHeader.moedas
                        )
                    )
                    .padding(.horizontal, pad)
                    .padding(.top, gap)

                    ProgressoDiarioCard(
                        dados: DadosProgressoDiario(
                            concluidos: missoesConcluidas,
                            total: max(missoes.count, 1)
                        )
                    )
                    .padding(.horizontal, pad)
                    .padding(.top, gap)

                    MissoesDoDiaView(missoes: $missoes) { missao in
                        Task { await toggleMissao(missao) }
                    }
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
        carregando = true
        erro = nil
        do {
            let data = try await RotinaPlusAPI.dashboard()
            perfil = data.perfil
            missoes = data.missoes.map { $0.asMissaoDoDia() }
            notificacoesNaoLidas = data.notificacoesNaoLidas
            xpHojeAPI = data.xpHoje

            if let nome = data.perfil.nomeHeroi, !nome.isEmpty {
                UserDefaults.standard.set(nome, forKey: "nome_heroi")
            }
            UserDefaults.standard.set(data.perfil.avatarAsset, forKey: "avatar_selecionado")
        } catch {
            erro = error.localizedDescription
        }
        carregando = false
    }

    @MainActor
    private func toggleMissao(_ missao: MissaoDoDia) async {
        // UI já alternou localmente em MissoesDoDiaView
        do {
            _ = try await RotinaPlusAPI.toggleMissao(id: missao.id)
            // Atualiza XP/nível do perfil
            let data = try await RotinaPlusAPI.dashboard()
            perfil = data.perfil
            notificacoesNaoLidas = data.notificacoesNaoLidas
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
