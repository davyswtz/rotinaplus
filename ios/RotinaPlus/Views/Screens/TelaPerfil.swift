import SwiftUI

// MARK: - Tela Perfil

struct TelaPerfil: View {
    var onPerfilAtualizado: (PerfilAPI) -> Void = { _ in }
    var onSair: () -> Void = {}

    @State private var stats: PerfilStatsAPI?
    @State private var periodo = "semana"
    @State private var carregando = true
    @State private var erro: String?
    @State private var precisaLogin = false

    @State private var mostrarNome = false
    @State private var mostrarAvatar = false
    @State private var mostrarClasse = false
    @State private var mostrarAddAmigo = false
    @State private var amigoStatsSelecionado: AmigoAPI?
    @State private var nomeEdit = ""
    @State private var codigoAmigo = ""
    @State private var amigos: [AmigoAPI] = []
    @State private var erroAmigo: String?
    @State private var adicionandoAmigo = false
    @State private var conviteEnviado = false
    @State private var lembretesAtivos = LembretesService.shared.ativos
    @State private var lembretesHoraManha = LembretesService.shared.horaManha
    @State private var lembretesHoraNoite = LembretesService.shared.horaNoite

    private let c = CoresPerfil.self

    private var perfil: PerfilAPI? { stats?.perfil }

    var body: some View {
        GeometryReader { geo in
            let pad = LayoutDashboard.paddingHorizontal(geo.size.width)
            let gap = LayoutDashboard.gapSecao(geo.size.width)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Perfil")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, pad)
                        .padding(.top, gap)

                    if carregando && stats == nil {
                        ProgressView().tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if precisaLogin || (erro != nil && stats == nil) {
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .font(.system(size: 48))
                                .foregroundStyle(c.laranja.opacity(0.9))

                            Text(precisaLogin ? "Sessão expirada" : "Não foi possível carregar o perfil")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)

                            Text(
                                precisaLogin
                                    ? "Faça login novamente para continuar."
                                    : (erro ?? "Tente de novo em instantes.")
                            )
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.55))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                            if precisaLogin {
                                Button {
                                    onSair()
                                } label: {
                                    Text("Entrar novamente")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(c.primario)
                                        )
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 32)
                                .padding(.top, 8)
                            } else {
                                Button {
                                    Task { await carregar() }
                                } label: {
                                    Text("Tentar de novo")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(c.laranja)
                                }
                                .buttonStyle(.plain)

                                Button {
                                    onSair()
                                } label: {
                                    Text("Entrar novamente")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.65))
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                        .padding(.horizontal, pad)
                    } else if let stats, let perfil {
                        heroCard(perfil, pad: pad)
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        nivelCard(stats.nivel, pad: pad)
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        periodoPicker
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        desempenhoResumo(stats.totais)
                            .padding(.horizontal, pad)
                            .padding(.top, 12)

                        graficoAcertosFalhas(stats.serie)
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        graficoXp(stats.serie)
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        areasCard(stats.porArea)
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        amigosSection
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        edicaoSection(perfil)
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        lembretesSection
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        Button(action: onSair) {
                            Text("Sair da conta")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.75))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.white.opacity(0.06))
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, pad)
                        .padding(.top, gap)
                        .padding(.bottom, 28)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .task { await carregar() }
        .sheet(isPresented: $mostrarNome) {
            editarNomeSheet
        }
        .sheet(isPresented: $mostrarAddAmigo) {
            adicionarAmigoSheet
        }
        .sheet(item: $amigoStatsSelecionado) { amigo in
            AmigoStatsSheet(amigo: amigo)
        }
        .sheet(isPresented: $mostrarAvatar) {
            editarAvatarSheet
        }
        .sheet(isPresented: $mostrarClasse) {
            editarClasseSheet
        }
    }

    // MARK: - Hero

    private func heroCard(_ p: PerfilAPI, pad: CGFloat) -> some View {
        HStack(spacing: 16) {
            Image(p.avatarAsset)
                .resizable()
                .scaledToFit()
                .frame(width: 78, height: 78)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(c.primario.opacity(0.5), lineWidth: 1.5)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(p.nomeExibicao)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                Text("Código: \(p.codigoExibicao)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(c.laranja.opacity(0.95))
                HStack(spacing: 6) {
                    Text(p.emojiClasse)
                    Text(p.classe)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(c.laranja)
                }
                Text("Nv. \(p.nivel) · \(p.moedas) moedas · \(p.streakDias)d streak")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(cardBg)
    }

    private func nivelCard(_ n: PerfilNivelAPI, pad: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("NÍVEL & EXPERIÊNCIA")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(c.label)
                Spacer()
                Text("Nv. \(n.atual)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(c.laranja)
            }

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(c.primario)
                        .frame(width: max(8, g.size.width * CGFloat(n.progresso)))
                }
            }
            .frame(height: 10)

            HStack {
                Text("\(n.xpAtual) / \(n.xpProximo) XP")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text("\(n.moedas) 🪙")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(16)
        .background(cardBg)
    }

    // MARK: - Periodo / resumo

    private var periodoPicker: some View {
        HStack(spacing: 8) {
            ForEach(["semana", "mes"], id: \.self) { p in
                Button {
                    periodo = p
                    Task { await carregar() }
                } label: {
                    Text(p == "semana" ? "7 dias" : "30 dias")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(periodo == p ? .white : .white.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(periodo == p ? c.primario.opacity(0.35) : Color.white.opacity(0.06))
                        )
                        .overlay(
                            Capsule().stroke(periodo == p ? c.primario : Color.white.opacity(0.1), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    private func desempenhoResumo(_ t: PerfilTotaisAPI) -> some View {
        HStack(spacing: 10) {
            miniStat("\(t.acertos)", "ACERTOS", c.verde)
            miniStat("\(t.falhas)", "FALHAS", Color(red: 0.95, green: 0.40, blue: 0.40))
            miniStat("\(t.taxaSucesso)%", "TAXA", c.laranja)
            miniStat("+\(t.xpGanho)", "XP", c.primario)
        }
    }

    private func miniStat(_ valor: String, _ label: String, _ cor: Color) -> some View {
        VStack(spacing: 6) {
            Text(valor)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(c.label)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(cor.opacity(0.25), lineWidth: 1)
                )
        )
    }

    // MARK: - Charts

    private func graficoAcertosFalhas(_ serie: [PerfilSerieDiaAPI]) -> some View {
        let maxY = max(serie.map { $0.acertos + $0.falhas }.max() ?? 1, 1)

        return VStack(alignment: .leading, spacing: 14) {
            Text("ACERTOS × FALHAS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(c.label)

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(serie) { dia in
                    VStack(spacing: 4) {
                        Spacer(minLength: 0)
                        if dia.falhas > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.95, green: 0.40, blue: 0.40).opacity(0.85))
                                .frame(height: CGFloat(dia.falhas) / CGFloat(maxY) * 90)
                        }
                        if dia.acertos > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(c.verde)
                                .frame(height: CGFloat(dia.acertos) / CGFloat(maxY) * 90)
                        }
                        if dia.acertos == 0 && dia.falhas == 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 6)
                        }
                        Text(dia.label)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120, alignment: .bottom)
                }
            }

            HStack(spacing: 16) {
                legendDot(c.verde, "Acertos")
                legendDot(Color(red: 0.95, green: 0.40, blue: 0.40), "Falhas")
            }
        }
        .padding(16)
        .background(cardBg)
    }

    private func graficoXp(_ serie: [PerfilSerieDiaAPI]) -> some View {
        let maxXp = max(serie.map(\.xp).max() ?? 1, 1)

        return VStack(alignment: .leading, spacing: 14) {
            Text("XP GANHO")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(c.label)

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(serie) { dia in
                    VStack(spacing: 4) {
                        if dia.xp > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(c.primario)
                                .frame(height: max(6, CGFloat(dia.xp) / CGFloat(maxXp) * 88))
                        } else {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 6)
                        }
                        Text(dia.label)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 110, alignment: .bottom)
                }
            }
        }
        .padding(16)
        .background(cardBg)
    }

    private func areasCard(_ a: PerfilAreasAPI) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("POR ÁREA")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(c.label)

            areaRow("🎯 Missões", a.missoes)
            areaRow("📓 Hábitos", a.habitos)
            areaRow("🏋️ Academia", a.academia)
            HStack {
                Text("🏃 Esportes")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(a.esportes.sessoes ?? 0) sessões · \(a.esportes.minutos ?? 0) min")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
            }
            .padding(.vertical, 8)
        }
        .padding(16)
        .background(cardBg)
    }

    private func areaRow(_ titulo: String, _ s: PerfilAreaStatsAPI) -> some View {
        let acertos = s.acertos ?? 0
        let falhas = s.falhas ?? 0
        let taxa = s.taxa ?? 0
        return HStack {
            Text(titulo)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Text("\(acertos)✓  \(falhas)✗  \(taxa)%")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.vertical, 6)
    }

    // MARK: - Amigos

    private var amigosSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("AMIGOS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(c.label)
                Spacer()
                Text("\(amigos.count)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.45))
            }

            if amigos.isEmpty {
                Text("Nenhum amigo ainda. Envie um pedido pelo código.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.45))
                    .padding(.vertical, 4)
            } else {
                ForEach(amigos) { amigo in
                    HStack(spacing: 12) {
                        Button {
                            amigoStatsSelecionado = amigo
                        } label: {
                            HStack(spacing: 12) {
                                Image(amigo.avatarAsset)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(amigo.nomeExibicao)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Text("\(amigo.codigoAmigo ?? "—") · Nv. \(amigo.nivel) · \(amigo.emojiClasse) \(amigo.classe)")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.45))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                        }
                        .buttonStyle(.plain)

                        Button {
                            Task { await removerAmigo(amigo) }
                        } label: {
                            Image(systemName: "person.badge.minus")
                                .foregroundStyle(c.falha)
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
                }
            }

            Button {
                codigoAmigo = ""
                erroAmigo = nil
                conviteEnviado = false
                mostrarAddAmigo = true
            } label: {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Adicionar amigo")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(c.primario)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(16)
        .background(cardBg)
    }

    // MARK: - Lembretes

    private var lembretesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LEMBRETES")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(c.label)

            Text("Notificações no celular para missões e hábitos.")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.45))

            Toggle(isOn: $lembretesAtivos) {
                Label("Ativar lembretes", systemImage: "bell.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .tint(c.primario)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
            .onChange(of: lembretesAtivos) { novo in
                LembretesService.shared.ativos = novo
                if novo {
                    Task {
                        _ = await LembretesService.shared.pedirPermissaoSeNecessario()
                        await LembretesService.shared.reagendarTudo()
                    }
                }
            }

            if lembretesAtivos {
                HStack {
                    Text("Manhã")
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Picker("", selection: $lembretesHoraManha) {
                        ForEach(5..<13, id: \.self) { h in
                            Text(String(format: "%02d:00", h)).tag(h)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(c.laranja)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
                .onChange(of: lembretesHoraManha) { h in
                    LembretesService.shared.horaManha = h
                }

                HStack {
                    Text("Noite")
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Picker("", selection: $lembretesHoraNoite) {
                        ForEach(17..<23, id: \.self) { h in
                            Text(String(format: "%02d:00", h)).tag(h)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(c.laranja)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
                .onChange(of: lembretesHoraNoite) { h in
                    LembretesService.shared.horaNoite = h
                }
            }
        }
        .padding(16)
        .background(cardBg)
    }

    // MARK: - Edição

    private func edicaoSection(_ p: PerfilAPI) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EDITAR HERÓI")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(c.label)

            botaoEdicao(titulo: "Nome", valor: p.nomeExibicao, icone: "pencil") {
                nomeEdit = p.nomeHeroi ?? ""
                mostrarNome = true
            }
            botaoEdicao(titulo: "Foto / avatar", valor: "Trocar imagem", icone: "person.crop.circle") {
                mostrarAvatar = true
            }
            botaoEdicao(titulo: "Classe", valor: "\(p.emojiClasse) \(p.classe)", icone: "shield") {
                mostrarClasse = true
            }
        }
        .padding(16)
        .background(cardBg)
    }

    private func botaoEdicao(titulo: String, valor: String, icone: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icone)
                    .foregroundStyle(c.laranja)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(titulo)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.45))
                    Text(valor)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
        }
        .buttonStyle(.plain)
    }

    private var editarNomeSheet: some View {
        NavigationStack {
            Form {
                TextField("Nome do herói", text: $nomeEdit)
            }
            .navigationTitle("Editar nome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { mostrarNome = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        Task {
                            let nome = nomeEdit.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !nome.isEmpty else { return }
                            if let p = try? await RotinaPlusAPI.atualizarPerfilCampos(nomeHeroi: nome) {
                                onPerfilAtualizado(p)
                                UserDefaults.standard.set(nome, forKey: "nome_heroi")
                                mostrarNome = false
                                await carregar()
                            }
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var editarNickSheet: some View {
        EmptyView()
    }

    private var adicionarAmigoSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("ABC123", text: $codigoAmigo)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                } footer: {
                    Text(erroAmigo ?? (conviteEnviado
                        ? "Solicitação enviada! Seu amigo precisa aceitar nas notificações."
                        : "Digite o código do herói (aparece no perfil dele)."))
                        .foregroundStyle(
                            erroAmigo != nil ? Color.red
                                : (conviteEnviado ? Color.green : Color.secondary)
                        )
                }
            }
            .navigationTitle("Adicionar amigo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { mostrarAddAmigo = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enviar") {
                        Task { await adicionarAmigo() }
                    }
                    .disabled(adicionandoAmigo || codigoAmigo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var editarAvatarSheet: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(AvatarExplorador.allCases) { avatar in
                        Button {
                            Task {
                                let key = AvatarHelper.apiKey(from: avatar.rawValue)
                                if let p = try? await RotinaPlusAPI.atualizarPerfilCampos(avatarKey: key) {
                                    onPerfilAtualizado(p)
                                    UserDefaults.standard.set(avatar.rawValue, forKey: "avatar_selecionado")
                                    mostrarAvatar = false
                                    await carregar()
                                }
                            }
                        } label: {
                            Image(avatar.rawValue)
                                .resizable()
                                .scaledToFit()
                                .padding(8)
                                .frame(height: 72)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.06)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            perfil?.avatarAsset == avatar.rawValue ? c.primario : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .background(Color(red: 0.06, green: 0.05, blue: 0.04))
            .navigationTitle("Escolher avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { mostrarAvatar = false }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var editarClasseSheet: some View {
        EditarClasseSheet(
            classeAtual: perfil?.classe ?? "",
            onFechar: { mostrarClasse = false },
            onSalvar: { classe in
                Task {
                    if let p = try? await RotinaPlusAPI.atualizarPerfilCampos(
                        classe: classe.nome,
                        emojiClasse: classe.emoji
                    ) {
                        onPerfilAtualizado(p)
                        mostrarClasse = false
                        await carregar()
                    }
                }
            }
        )
    }

    // MARK: - Helpers

    private var cardBg: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white.opacity(0.055))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            )
    }

    private func legendDot(_ cor: Color, _ texto: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(cor).frame(width: 8, height: 8)
            Text(texto)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    @MainActor
    private func carregar() async {
        if stats == nil { carregando = true }
        erro = nil
        precisaLogin = false

        if AuthManager.shared.token == nil {
            precisaLogin = true
            carregando = false
            return
        }

        do {
            if let cachedStats = OfflineStore.shared.load(
                PerfilStatsAPI.self,
                key: OfflineCacheKey.perfilStats(periodo: periodo)
            ) {
                stats = cachedStats
                carregando = false
            }
            if let cachedAmigos = OfflineStore.shared.load(AmigosListaAPI.self, key: .amigos) {
                amigos = cachedAmigos.amigos
            }

            async let statsTask = RotinaPlusAPI.perfilStats(periodo: periodo)
            async let amigosTask = RotinaPlusAPI.listarAmigos()
            stats = try await statsTask
            if let lista = try? await amigosTask {
                amigos = lista.amigos
            }
            if let p = stats?.perfil {
                onPerfilAtualizado(p)
            }
            await OfflineSyncEngine.shared.flush()
        } catch let apiError as APIError where apiError.isUnauthorized {
            precisaLogin = true
            erro = "Sessão expirada ou não autenticado."
        } catch {
            let msg = error.localizedDescription.lowercased()
            if msg.contains("unauthenticated") || msg.contains("não autentic") || msg.contains("nao autentic") {
                precisaLogin = true
            }
            if stats == nil {
                erro = error.localizedDescription
            }
        }
        carregando = false
    }

    @MainActor
    private func adicionarAmigo() async {
        let codigo = codigoAmigo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !codigo.isEmpty else { return }
        adicionandoAmigo = true
        erroAmigo = nil
        conviteEnviado = false
        defer { adicionandoAmigo = false }
        do {
            _ = try await RotinaPlusAPI.convidarAmigo(codigo: codigo)
            conviteEnviado = true
        } catch {
            erroAmigo = error.localizedDescription
        }
    }

    @MainActor
    private func removerAmigo(_ amigo: AmigoAPI) async {
        do {
            try await RotinaPlusAPI.removerAmigo(id: amigo.id)
            amigos.removeAll { $0.id == amigo.id }
        } catch {
            // silencioso — lista permanece
        }
    }
}

private struct EditarClasseSheet: View {
    let classeAtual: String
    var onFechar: () -> Void
    var onSalvar: (ClasseHeroi) -> Void

    @State private var classes: [ClasseHeroi] = []
    @State private var selecionada: ClasseHeroi?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(classes) { classe in
                        Button {
                            selecionada = classe
                        } label: {
                            HStack(spacing: 12) {
                                Text(classe.emoji).font(.title)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(classe.nome)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text(classe.descricao)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                Spacer()
                                if (selecionada?.nome ?? classeAtual) == classe.nome {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color(red: 0.910, green: 0.471, blue: 0.188))
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        (selecionada?.nome ?? classeAtual) == classe.nome
                                            ? Color(red: 0.910, green: 0.471, blue: 0.188)
                                            : Color.white.opacity(0.08),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .background(Color(red: 0.06, green: 0.05, blue: 0.04))
            .navigationTitle("Trocar classe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar", action: onFechar)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        if let s = selecionada { onSalvar(s) }
                    }
                    .disabled(selecionada == nil)
                }
            }
            .task {
                classes = (try? await RotinaPlusAPI.classes()) ?? []
                selecionada = classes.first { $0.nome == classeAtual }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct AmigoStatsSheet: View {
    let amigo: AmigoAPI

    @Environment(\.dismiss) private var dismiss
    @State private var stats: AmigoStatsAPI?
    @State private var periodo = "semana"
    @State private var carregando = true
    @State private var erro: String?

    private let c = CoresPerfil.self

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 14) {
                        Image(amigo.avatarAsset)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(amigo.nomeExibicao)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                            Text("\(amigo.codigoAmigo ?? "—") · \(amigo.emojiClasse) \(amigo.classe)")
                                .font(.subheadline)
                                .foregroundStyle(c.laranja)
                        }
                        Spacer()
                    }

                    HStack(spacing: 8) {
                        ForEach(["semana", "mes"], id: \.self) { p in
                            Button {
                                periodo = p
                                Task { await carregar() }
                            } label: {
                                Text(p == "semana" ? "7 dias" : "30 dias")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(
                                            periodo == p
                                                ? c.primario.opacity(0.85)
                                                : Color.white.opacity(0.08)
                                        )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if carregando && stats == nil {
                        ProgressView().tint(.white).frame(maxWidth: .infinity).padding(.top, 24)
                    } else if let erro, stats == nil {
                        Text(erro)
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                    } else if let stats {
                        let n = stats.nivel
                        let t = stats.totais

                        VStack(alignment: .leading, spacing: 10) {
                            Text("NÍVEL")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundStyle(c.label)
                            Text("Nv. \(n.atual) · \(n.xpAtual)/\(n.xpProximo) XP · \(n.moedas) 🪙")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                            GeometryReader { g in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.white.opacity(0.08))
                                    Capsule()
                                        .fill(c.primario)
                                        .frame(width: max(8, g.size.width * CGFloat(n.progresso)))
                                }
                            }
                            .frame(height: 10)
                        }
                        .padding(16)
                        .background(card)

                        HStack(spacing: 8) {
                            miniStat("\(t.acertos)", "ACERTOS", c.verde)
                            miniStat("\(t.falhas)", "FALHAS", c.falha)
                            miniStat("\(t.taxaSucesso)%", "TAXA", c.laranja)
                            miniStat("+\(t.xpGanho)", "XP", c.primario)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("POR ÁREA")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundStyle(c.label)
                            areaLinha("🎯 Missões", stats.porArea.missoes)
                            areaLinha("📓 Hábitos", stats.porArea.habitos)
                            areaLinha("🏋️ Academia", stats.porArea.academia)
                            Text("🏃 Esportes · \(stats.porArea.esportes.sessoes ?? 0) sessões · \(stats.porArea.esportes.minutos ?? 0) min")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .padding(16)
                        .background(card)

                        Text("Streak \(t.streakAtual)d · \(t.diasCompletos) dias completos · \(t.sequenciaTreinos) treinos em sequência")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                    }
                }
                .padding(16)
            }
            .background(Color(red: 0.06, green: 0.05, blue: 0.04).ignoresSafeArea())
            .navigationTitle("Stats do amigo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
        .task { await carregar() }
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(0.055))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            )
    }

    private func miniStat(_ valor: String, _ label: String, _ cor: Color) -> some View {
        VStack(spacing: 4) {
            Text(valor)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(cor)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
    }

    private func areaLinha(_ titulo: String, _ s: PerfilAreaStatsAPI) -> some View {
        HStack {
            Text(titulo)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Text("\(s.acertos ?? 0)✓  \(s.falhas ?? 0)✗  \(s.taxa ?? 0)%")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.55))
        }
    }

    @MainActor
    private func carregar() async {
        if stats == nil { carregando = true }
        erro = nil
        do {
            stats = try await RotinaPlusAPI.statsAmigo(id: amigo.id, periodo: periodo)
        } catch {
            erro = error.localizedDescription
        }
        carregando = false
    }
}

private enum CoresPerfil {
    static let primario = Color(red: 0.910, green: 0.471, blue: 0.188)
    static let laranja = Color(red: 1.0, green: 0.608, blue: 0.290)
    static let verde = Color(red: 0.29, green: 0.87, blue: 0.50)
    static let falha = Color(red: 0.95, green: 0.40, blue: 0.40)
    static let label = Color.white.opacity(0.42)
}
