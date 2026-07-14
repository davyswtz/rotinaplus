import SwiftUI

/// Tela dashboard inicial — layout responsivo para todos os iPhones.
struct HomeView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var mostrarNotificacoes = false
    @State private var notificacoesNaoLidas = 2
    @State private var missoes = MissaoDoDia.exemplos
    @State private var abaSelecionada: AbaFooter = .inicio

    private var dadosHeader: DadosHeaderApp {
        let nomeSalvo = UserDefaults.standard.string(forKey: "nome_heroi")?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let nome = (nomeSalvo?.isEmpty == false) ? nomeSalvo! : "herói"
        let avatar = UserDefaults.standard.string(forKey: "avatar_selecionado")
            ?? AvatarExplorador.guaraSerio.rawValue
        return DadosHeaderApp(
            nomeUsuario: nome.lowercased(),
            nivel: 1,
            streakDias: 3,
            moedas: 480,
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
        .fullScreenCover(isPresented: $mostrarNotificacoes) {
            TelaNotificacoes {
                mostrarNotificacoes = false
                notificacoesNaoLidas = 0
            }
        }
    }

    private func conteudoInicio(pad: CGFloat, gap: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                CardPerfilHeroi(
                    dados: DadosCardPerfil(
                        nomeUsuario: dadosHeader.nomeUsuario,
                        classe: "Sábio",
                        emojiClasse: "🔮",
                        nivel: dadosHeader.nivel,
                        xpAtual: 240,
                        xpProximoNivel: 500,
                        avatarAsset: dadosHeader.avatarAsset
                    )
                )
                .padding(.horizontal, pad)
                .padding(.top, gap)

                GradeStatsDashboard(
                    dados: DadosGradeStats(
                        streakDias: dadosHeader.streakDias,
                        habitosHojeConcluidos: missoesConcluidas,
                        habitosHojeTotal: missoes.count,
                        xpHoje: xpHoje,
                        moedas: dadosHeader.moedas
                    )
                )
                .padding(.horizontal, pad)
                .padding(.top, gap)

                ProgressoDiarioCard(
                    dados: DadosProgressoDiario(
                        concluidos: missoesConcluidas,
                        total: missoes.count
                    )
                )
                .padding(.horizontal, pad)
                .padding(.top, gap)

                MissoesDoDiaView(missoes: $missoes)
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
}

#Preview {
    HomeView()
}
