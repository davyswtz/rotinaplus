import SwiftUI

// MARK: - Helpers

enum MoedaBR {
    static func formatar(_ centavos: Int, sinal: Bool = false) -> String {
        let absCentavos = abs(centavos)
        let reais = absCentavos / 100
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        let numero = formatter.string(from: NSNumber(value: reais)) ?? "\(reais)"
        let base = "R$\(numero)"
        guard sinal else { return base }
        if centavos > 0 { return "+\(base)" }
        if centavos < 0 { return "-\(base)" }
        return base
    }

    static func dataCurta(_ iso: String) -> String {
        let inFmt = DateFormatter()
        inFmt.locale = Locale(identifier: "en_US_POSIX")
        inFmt.dateFormat = "yyyy-MM-dd"
        guard let date = inFmt.date(from: iso) else { return iso }
        let out = DateFormatter()
        out.locale = Locale(identifier: "pt_BR")
        out.dateFormat = "dd MMM"
        return out.string(from: date)
    }

    static func corHex(_ hex: String) -> Color {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else {
            return Color.white.opacity(0.4)
        }
        return Color(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

private enum CoresFinancas {
    static let roxo = Color(red: 0.478, green: 0.259, blue: 0.961)
    static let verde = Color(red: 0.29, green: 0.87, blue: 0.50)
    static let vermelho = Color(red: 0.95, green: 0.35, blue: 0.45)
    static let card = Color.white.opacity(0.055)
    static let borda = Color.white.opacity(0.08)
    static let label = Color.white.opacity(0.42)
    static let saldoFundo = Color(red: 0.06, green: 0.22, blue: 0.14)
    static let saldoGlow = Color(red: 0.20, green: 0.55, blue: 0.32).opacity(0.45)
}

// MARK: - Tela

struct TelaFinancas: View {
    @State private var dados: FinancasAPI?
    @State private var mesSelecionado: String?
    @State private var carregando = true
    @State private var erro: String?
    @State private var mostrarAdicionar = false
    @State private var mostrarTransacoes = false
    @State private var mostrarMetas = false
    @State private var mostrarPluggy = false
    @State private var pluggyToken: String?
    @State private var syncMensagem: String?
    @State private var syncando = false

    var body: some View {
        GeometryReader { geo in
            let pad = LayoutDashboard.paddingHorizontal(geo.size.width)
            let gap = LayoutDashboard.gapSecao(geo.size.width)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Finanças")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                        if let label = dados?.mesLabel {
                            Text(label)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(CoresFinancas.label)
                        }
                    }
                    .padding(.horizontal, pad)
                    .padding(.top, gap)

                    if carregando && dados == nil {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 48)
                    } else if let erro, dados == nil {
                        Text(erro)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, pad)
                            .padding(.top, gap)
                        Button("Tentar de novo") {
                            Task { await carregar() }
                        }
                        .foregroundStyle(CoresFinancas.roxo)
                        .padding(.horizontal, pad)
                        .padding(.top, 8)
                    } else if let dados {
                        SeletorMesesFinancas(
                            meses: dados.meses,
                            selecionado: dados.anoMes
                        ) { mes in
                            mesSelecionado = mes
                            Task { await carregar(mes: mes) }
                        }
                        .padding(.horizontal, pad)
                        .padding(.top, gap)

                        CardSaldoFinancas(
                            saldo: dados.saldoCentavos,
                            receita: dados.receitaCentavos,
                            gastos: dados.gastosCentavos
                        )
                        .padding(.horizontal, pad)
                        .padding(.top, gap)

                        BancoConnectCard(
                            pluggy: dados.pluggy,
                            syncando: syncando,
                            mensagem: syncMensagem,
                            onConectar: { Task { await conectarBanco() } },
                            onSincronizar: { Task { await sincronizarBanco() } }
                        )
                        .padding(.horizontal, pad)
                        .padding(.top, gap)

                        AtalhosFinancasView(
                            onTransacoes: { mostrarTransacoes = true },
                            onAdicionar: { mostrarAdicionar = true },
                            onMetas: { mostrarMetas = true }
                        )
                        .padding(.horizontal, pad)
                        .padding(.top, gap)

                        GraficoReceitaGastos(serie: dados.serieMensal)
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        DistribuicaoGastosCard(itens: dados.distribuicao)
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        RecentesFinancasView(
                            itens: dados.recentes,
                            onVerTodas: { mostrarTransacoes = true },
                            onAdicionar: { mostrarAdicionar = true }
                        )
                        .padding(.horizontal, pad)
                        .padding(.top, gap)
                        .padding(.bottom, 28)
                    }
                }
            }
            .refreshable { await carregar(mes: mesSelecionado ?? dados?.anoMes) }
        }
        .task { await carregar() }
        .sheet(isPresented: $mostrarAdicionar) {
            if let dados {
                AdicionarTransacaoSheet(categorias: dados.categorias) {
                    mostrarAdicionar = false
                    Task { await carregar(mes: mesSelecionado ?? dados.anoMes) }
                }
            }
        }
        .sheet(isPresented: $mostrarTransacoes) {
            if let dados {
                TodasTransacoesSheet(
                    transacoes: dados.transacoes,
                    onExcluir: { id in
                        Task {
                            try? await RotinaPlusAPI.excluirTransacao(id: id)
                            await carregar(mes: mesSelecionado ?? dados.anoMes)
                        }
                    },
                    onFechar: { mostrarTransacoes = false }
                )
            }
        }
        .sheet(isPresented: $mostrarMetas) {
            if let dados {
                MetasFinancasSheet(
                    metas: dados.metas,
                    onCriar: { titulo, alvo in
                        Task {
                            _ = try? await RotinaPlusAPI.criarMeta(
                                titulo: titulo,
                                icone: "🎯",
                                valorAlvoCentavos: alvo
                            )
                            await carregar(mes: mesSelecionado ?? dados.anoMes)
                        }
                    },
                    onAtualizar: { id, atual in
                        Task {
                            _ = try? await RotinaPlusAPI.atualizarMeta(
                                id: id,
                                valorAtualCentavos: atual
                            )
                            await carregar(mes: mesSelecionado ?? dados.anoMes)
                        }
                    },
                    onFechar: { mostrarMetas = false }
                )
            }
        }
        .sheet(isPresented: $mostrarPluggy) {
            if let token = pluggyToken {
                PluggyConnectSheet(
                    accessToken: token,
                    onSuccess: { itemId in
                        mostrarPluggy = false
                        Task { await vincularItem(itemId) }
                    },
                    onCancel: { mostrarPluggy = false }
                )
            }
        }
    }

    @MainActor
    private func carregar(mes: String? = nil) async {
        if dados == nil { carregando = true }
        erro = nil
        do {
            let data = try await RotinaPlusAPI.financas(mes: mes)
            dados = data
            mesSelecionado = data.anoMes
        } catch {
            erro = error.localizedDescription
        }
        carregando = false
    }

    @MainActor
    private func conectarBanco() async {
        syncMensagem = nil
        syncando = true
        do {
            let token = try await RotinaPlusAPI.pluggyConnectToken()
            if token.mode == "local" {
                await vincularItem("local-sandbox")
            } else {
                pluggyToken = token.accessToken
                mostrarPluggy = true
            }
        } catch {
            syncMensagem = error.localizedDescription
        }
        syncando = false
    }

    @MainActor
    private func vincularItem(_ itemId: String) async {
        syncando = true
        do {
            let result = try await RotinaPlusAPI.pluggyVincular(itemId: itemId)
            syncMensagem = "Importadas \(result.importadas) · atualizadas \(result.atualizadas)"
            await carregar(mes: mesSelecionado ?? dados?.anoMes)
        } catch {
            syncMensagem = error.localizedDescription
        }
        syncando = false
    }

    @MainActor
    private func sincronizarBanco() async {
        syncando = true
        syncMensagem = nil
        do {
            let result = try await RotinaPlusAPI.pluggySincronizar()
            syncMensagem = "Importadas \(result.importadas) · atualizadas \(result.atualizadas)"
            await carregar(mes: mesSelecionado ?? dados?.anoMes)
        } catch {
            syncMensagem = error.localizedDescription
        }
        syncando = false
    }
}

// MARK: - Banco / Pluggy

private struct BancoConnectCard: View {
    let pluggy: FinancasPluggyAPI?
    var syncando: Bool
    var mensagem: String?
    var onConectar: () -> Void
    var onSincronizar: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BANCO (SANDBOX)")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(CoresFinancas.label)

            if let nome = pluggy?.conexoes.first?.connectorName {
                Text(nome)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Conectado · sync automático via Pluggy")
                    .font(.system(size: 12))
                    .foregroundStyle(CoresFinancas.label)
            } else {
                Text("Conecte o sandbox para importar transações automaticamente.")
                    .font(.system(size: 13))
                    .foregroundStyle(CoresFinancas.label)
            }

            HStack(spacing: 10) {
                Button(action: onConectar) {
                    Text(pluggy?.temConexao == true ? "Reconectar" : "Conectar sandbox")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(CoresFinancas.roxo))
                }
                .buttonStyle(.plain)
                .disabled(syncando)

                if pluggy?.temConexao == true {
                    Button(action: onSincronizar) {
                        Text(syncando ? "…" : "Sincronizar")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(CoresFinancas.roxo)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(CoresFinancas.roxo, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(syncando)
                }
            }

            if let mensagem {
                Text(mensagem)
                    .font(.system(size: 12))
                    .foregroundStyle(CoresFinancas.verde)
            }

            if pluggy?.configured != true && pluggy?.localSandbox == true {
                Text("Modo local: sem chaves Pluggy ainda. Toque em Conectar para importar o sandbox de teste.")
                    .font(.system(size: 11))
                    .foregroundStyle(CoresFinancas.label)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(CoresFinancas.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(CoresFinancas.borda, lineWidth: 1)
        )
    }
}

// MARK: - Seletor meses

private struct SeletorMesesFinancas: View {
    let meses: [FinancasMesAPI]
    let selecionado: String
    var onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(meses) { mes in
                    let ativo = mes.anoMes == selecionado
                    Button {
                        onSelect(mes.anoMes)
                    } label: {
                        Text(mes.curto)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ativo ? .white : CoresFinancas.label)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(ativo ? CoresFinancas.roxo : CoresFinancas.card)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(ativo ? CoresFinancas.roxo : CoresFinancas.borda, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Saldo

private struct CardSaldoFinancas: View {
    let saldo: Int
    let receita: Int
    let gastos: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SALDO DISPONÍVEL")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(CoresFinancas.verde.opacity(0.85))

            Text(MoedaBR.formatar(saldo))
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11, weight: .bold))
                        Text("Receita")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(CoresFinancas.verde)
                    Text(MoedaBR.formatar(receita))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("Gastos")
                            .font(.system(size: 12, weight: .semibold))
                        Image(systemName: "arrow.down.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(CoresFinancas.vermelho)
                    Text(MoedaBR.formatar(gastos))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(CoresFinancas.saldoFundo)
                Circle()
                    .fill(CoresFinancas.saldoGlow)
                    .frame(width: 140, height: 140)
                    .offset(x: 30, y: 10)
                    .blur(radius: 8)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Atalhos

private struct AtalhosFinancasView: View {
    var onTransacoes: () -> Void
    var onAdicionar: () -> Void
    var onMetas: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            atalho("Transações", "list.clipboard", onTransacoes)
            atalho("Adicionar", "plus", onAdicionar)
            atalho("Metas", "target", onMetas)
        }
    }

    private func atalho(_ titulo: String, _ icone: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icone)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(CoresFinancas.roxo)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(CoresFinancas.roxo.opacity(0.18)))
                Text(titulo)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(CoresFinancas.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(CoresFinancas.borda, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Gráfico linha

private struct GraficoReceitaGastos: View {
    let serie: [FinancasSerieAPI]

    private var maxValor: Double {
        let vals = serie.flatMap { [$0.receitaCentavos, $0.gastosCentavos] }.map(Double.init)
        return max(vals.max() ?? 1, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("RECEITA VS GASTOS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(CoresFinancas.label)
                Spacer()
            }

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let n = max(serie.count, 1)
                let step = n > 1 ? w / CGFloat(n - 1) : w

                ZStack {
                    Path { path in
                        for (i, ponto) in serie.enumerated() {
                            let x = CGFloat(i) * step
                            let y = h - CGFloat(Double(ponto.receitaCentavos) / maxValor) * (h - 8)
                            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                    }
                    .stroke(CoresFinancas.roxo, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                    Path { path in
                        for (i, ponto) in serie.enumerated() {
                            let x = CGFloat(i) * step
                            let y = h - CGFloat(Double(ponto.gastosCentavos) / maxValor) * (h - 8)
                            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                    }
                    .stroke(CoresFinancas.vermelho.opacity(0.75), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 4]))
                }
            }
            .frame(height: 110)

            HStack {
                ForEach(serie) { ponto in
                    Text(ponto.curto)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(CoresFinancas.label)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(CoresFinancas.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(CoresFinancas.borda, lineWidth: 1)
        )
    }
}

// MARK: - Donut

private struct DistribuicaoGastosCard: View {
    let itens: [FinancasDistribuicaoAPI]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("DISTRIBUIÇÃO DE GASTOS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(CoresFinancas.label)

            if itens.isEmpty {
                Text("Nenhuma despesa neste mês.")
                    .font(.subheadline)
                    .foregroundStyle(CoresFinancas.label)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 20)
            } else {
                HStack(alignment: .center, spacing: 16) {
                    DonutChartFinancas(itens: itens)
                        .frame(width: 120, height: 120)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(itens) { item in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(MoedaBR.corHex(item.cor))
                                    .frame(width: 8, height: 8)
                                Text(item.nome)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.85))
                                    .lineLimit(1)
                                Spacer(minLength: 4)
                                Text(MoedaBR.formatar(item.valorCentavos))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(CoresFinancas.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(CoresFinancas.borda, lineWidth: 1)
        )
    }
}

private struct DonutChartFinancas: View {
    let itens: [FinancasDistribuicaoAPI]

    private var total: Double {
        max(itens.map { Double($0.valorCentavos) }.reduce(0, +), 1)
    }

    var body: some View {
        Canvas { context, size in
            let mid = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            let lineWidth: CGFloat = 22
            var start = Angle.degrees(-90)

            for item in itens {
                let frac = Double(item.valorCentavos) / total
                let end = start + .degrees(360 * frac)
                var path = Path()
                path.addArc(center: mid, radius: radius - lineWidth / 2, startAngle: start, endAngle: end, clockwise: false)
                context.stroke(
                    path,
                    with: .color(MoedaBR.corHex(item.cor)),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                )
                start = end
            }
        }
    }
}

// MARK: - Recentes

private struct RecentesFinancasView: View {
    let itens: [FinancasTransacaoAPI]
    var onVerTodas: () -> Void
    var onAdicionar: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recentes")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                if !itens.isEmpty {
                    Button("Ver todas", action: onVerTodas)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(CoresFinancas.roxo)
                }
            }

            if itens.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Nenhuma transação neste mês.")
                        .font(.subheadline)
                        .foregroundStyle(CoresFinancas.label)
                    Button("Adicionar primeira transação", action: onAdicionar)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(CoresFinancas.roxo)
                }
                .padding(.vertical, 8)
            } else {
                ForEach(itens) { tx in
                    LinhaTransacaoFinancas(tx: tx)
                }
            }
        }
    }
}

private struct LinhaTransacaoFinancas: View {
    let tx: FinancasTransacaoAPI

    var body: some View {
        HStack(spacing: 12) {
            Text(tx.icone)
                .font(.system(size: 20))
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(CoresFinancas.card)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(tx.titulo)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text("\(tx.categoriaNome) · \(MoedaBR.dataCurta(tx.data))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(CoresFinancas.label)
            }

            Spacer()

            Text(MoedaBR.formatar(tx.isReceita ? tx.valorCentavos : -tx.valorCentavos, sinal: true))
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(tx.isReceita ? CoresFinancas.verde : CoresFinancas.vermelho)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(CoresFinancas.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CoresFinancas.borda, lineWidth: 1)
        )
    }
}

// MARK: - Sheets

private struct AdicionarTransacaoSheet: View {
    let categorias: FinancasCategoriasAPI
    var onSalvo: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var tipo = "despesa"
    @State private var categoria = "alimentacao"
    @State private var titulo = ""
    @State private var valorTexto = ""
    @State private var data = Date()
    @State private var salvando = false
    @State private var erro: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Tipo") {
                    Picker("Tipo", selection: $tipo) {
                        Text("Despesa").tag("despesa")
                        Text("Receita").tag("receita")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: tipo) { novo in
                        if novo == "receita" {
                            categoria = "receita"
                        } else if categoria == "receita" {
                            categoria = categorias.despesas.first?.chave ?? "outros"
                        }
                    }
                }

                if tipo == "despesa" {
                    Section("Categoria") {
                        Picker("Categoria", selection: $categoria) {
                            ForEach(categorias.despesas) { cat in
                                Text("\(cat.icone) \(cat.nome)").tag(cat.chave)
                            }
                        }
                    }
                }

                Section("Detalhes") {
                    TextField("Título", text: $titulo)
                    TextField("Valor (R$)", text: $valorTexto)
                        .keyboardType(.decimalPad)
                    DatePicker("Data", selection: $data, displayedComponents: .date)
                }

                if let erro {
                    Section {
                        Text(erro).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Nova transação")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(salvando ? "…" : "Salvar") {
                        Task { await salvar() }
                    }
                    .disabled(salvando)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if tipo == "despesa" {
                categoria = categorias.despesas.first?.chave ?? "outros"
            }
        }
    }

    @MainActor
    private func salvar() async {
        erro = nil
        let limpo = valorTexto
            .replacingOccurrences(of: "R$", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
        guard let reais = Double(limpo), reais > 0 else {
            erro = "Informe um valor válido."
            return
        }
        let tituloTrim = titulo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard tituloTrim.count >= 2 else {
            erro = "Informe um título."
            return
        }

        salvando = true
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "yyyy-MM-dd"
        let cat = tipo == "receita" ? "receita" : categoria
        let icone = tipo == "receita"
            ? categorias.receita.icone
            : (categorias.despesas.first { $0.chave == categoria }?.icone ?? "💳")

        do {
            _ = try await RotinaPlusAPI.criarTransacao(
                tipo: tipo,
                categoria: cat,
                titulo: tituloTrim,
                icone: icone,
                valorCentavos: Int((reais * 100).rounded()),
                data: fmt.string(from: data)
            )
            onSalvo()
            dismiss()
        } catch {
            erro = error.localizedDescription
        }
        salvando = false
    }
}

private struct TodasTransacoesSheet: View {
    let transacoes: [FinancasTransacaoAPI]
    var onExcluir: (Int) -> Void
    var onFechar: () -> Void

    var body: some View {
        NavigationStack {
            List {
                if transacoes.isEmpty {
                    Text("Nenhuma transação.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(transacoes) { tx in
                        LinhaTransacaoFinancas(tx: tx)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .swipeActions {
                                Button(role: .destructive) {
                                    onExcluir(tx.id)
                                } label: {
                                    Label("Excluir", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Transações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar", action: onFechar)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct MetasFinancasSheet: View {
    let metas: [FinancasMetaAPI]
    var onCriar: (String, Int) -> Void
    var onAtualizar: (Int, Int) -> Void
    var onFechar: () -> Void

    @State private var novaTitulo = ""
    @State private var novaAlvo = ""
    @State private var edicaoValor: [Int: String] = [:]

    var body: some View {
        NavigationStack {
            List {
                Section("Suas metas") {
                    if metas.isEmpty {
                        Text("Nenhuma meta ainda. Crie a primeira abaixo.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(metas) { meta in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("\(meta.icone) \(meta.titulo)")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(Int(meta.percentual))%")
                                        .foregroundStyle(CoresFinancas.roxo)
                                }
                                ProgressView(value: min(meta.percentual / 100, 1))
                                    .tint(CoresFinancas.roxo)
                                Text("\(MoedaBR.formatar(meta.valorAtualCentavos)) / \(MoedaBR.formatar(meta.valorAlvoCentavos))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                HStack {
                                    TextField(
                                        "Valor atual (R$)",
                                        text: Binding(
                                            get: {
                                                edicaoValor[meta.id]
                                                    ?? String(format: "%.2f", Double(meta.valorAtualCentavos) / 100)
                                            },
                                            set: { edicaoValor[meta.id] = $0 }
                                        )
                                    )
                                    .keyboardType(.decimalPad)

                                    Button("Salvar") {
                                        let texto = edicaoValor[meta.id]
                                            ?? String(format: "%.2f", Double(meta.valorAtualCentavos) / 100)
                                        let limpo = texto
                                            .replacingOccurrences(of: ",", with: ".")
                                            .replacingOccurrences(of: " ", with: "")
                                        guard let reais = Double(limpo), reais >= 0 else { return }
                                        onAtualizar(meta.id, Int((reais * 100).rounded()))
                                    }
                                    .font(.caption.weight(.semibold))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section("Nova meta") {
                    TextField("Título", text: $novaTitulo)
                    TextField("Valor alvo (R$)", text: $novaAlvo)
                        .keyboardType(.decimalPad)
                    Button("Criar meta") {
                        let limpo = novaAlvo
                            .replacingOccurrences(of: ",", with: ".")
                            .replacingOccurrences(of: " ", with: "")
                        guard let reais = Double(limpo), reais >= 1,
                              novaTitulo.trimmingCharacters(in: .whitespaces).count >= 2 else { return }
                        onCriar(
                            novaTitulo.trimmingCharacters(in: .whitespaces),
                            Int((reais * 100).rounded())
                        )
                        novaTitulo = ""
                        novaAlvo = ""
                    }
                }
            }
            .navigationTitle("Metas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar", action: onFechar)
                }
            }
        }
        .preferredColorScheme(.dark)
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
        TelaFinancas()
    }
    .preferredColorScheme(.dark)
}
