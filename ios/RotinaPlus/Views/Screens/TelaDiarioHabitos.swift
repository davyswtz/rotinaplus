import SwiftUI

private enum CoresDiario {
    static let primario = Color(red: 0.910, green: 0.471, blue: 0.188)
    static let verde = Color(red: 0.29, green: 0.87, blue: 0.50)
    static let card = Color.white.opacity(0.055)
    static let borda = Color.white.opacity(0.08)
    static let label = Color.white.opacity(0.42)
    static let streak = Color(red: 1.0, green: 0.55, blue: 0.28)
}

private enum AreaHabito {
    static func label(_ area: String) -> String {
        switch area {
        case "academia": return "Academia"
        case "financas": return "Finanças"
        case "estudos": return "Estudos"
        case "bemestar": return "Bem-estar"
        default: return "Geral"
        }
    }

    static func cor(_ area: String) -> Color {
        switch area {
        case "academia": return Color(red: 1.0, green: 0.48, blue: 0.28)
        case "financas": return Color(red: 0.35, green: 0.86, blue: 0.52)
        case "estudos": return Color(red: 0.35, green: 0.85, blue: 0.92)
        case "bemestar": return Color(red: 0.91, green: 0.72, blue: 0.42)
        default: return CoresDiario.primario
        }
    }
}

/// Diário de hábitos — tracker + journal integrado às áreas do app.
struct TelaDiarioHabitos: View {
    var onAbrirArea: ((AbaFooter) -> Void)?

    @State private var journal: HabitoJournalAPI?
    @State private var dataSelecionada: String?
    @State private var carregando = true
    @State private var erro: String?
    @State private var mensagemBonus: String?
    @State private var mostrarCriar = false
    @State private var itemNota: HabitoItemJournalAPI?

    private var dataAtual: String {
        dataSelecionada ?? journal?.data ?? ""
    }

    var body: some View {
        GeometryReader { geo in
            let pad = LayoutDashboard.paddingHorizontal(geo.size.width)
            let gap = LayoutDashboard.gapSecao(geo.size.width)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Diário")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                        Button {
                            mostrarCriar = true
                        } label: {
                            Label("Novo", systemImage: "plus")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(CoresDiario.primario)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(CoresDiario.primario.opacity(0.18)))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, pad)
                    .padding(.top, gap)

                    if carregando && journal == nil {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if let erro, journal == nil {
                        Text(erro)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, pad)
                            .padding(.top, gap)
                        Button("Tentar de novo") {
                            Task { await carregar() }
                        }
                        .foregroundStyle(CoresDiario.primario)
                        .padding(.horizontal, pad)
                        .padding(.top, 8)
                    } else if let journal {
                        if let mensagemBonus {
                            Text(mensagemBonus)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(CoresDiario.verde)
                                .padding(.horizontal, pad)
                                .padding(.top, 10)
                        }

                        ResumoDiarioCard(resumo: journal.resumo)
                            .padding(.horizontal, pad)
                            .padding(.top, gap)

                        SemanaHeatmapView(
                            semana: journal.semana,
                            selecionada: dataAtual,
                            hoje: journal.hoje
                        ) { dia in
                            dataSelecionada = dia
                            Task { await carregar(data: dia) }
                        }
                        .padding(.horizontal, pad)
                        .padding(.top, gap)

                        Text("HÁBITOS DO DIA")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.0)
                            .foregroundStyle(CoresDiario.label)
                            .padding(.horizontal, pad)
                            .padding(.top, gap + 4)

                        if journal.itens.isEmpty {
                            EmptyHabitosView(
                                sugestoes: journal.sugestoes,
                                onSugestao: { s in
                                    Task { await criarDeSugestao(s) }
                                }
                            )
                            .padding(.horizontal, pad)
                            .padding(.top, 12)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(journal.itens) { item in
                                    HabitoJournalRow(
                                        item: item,
                                        onToggle: {
                                            Task { await toggle(item) }
                                        },
                                        onNota: { itemNota = item },
                                        onArea: {
                                            if let aba = abaParaArea(item.habito.area) {
                                                onAbrirArea?(aba)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, pad)
                            .padding(.top, 12)
                            .padding(.bottom, 28)
                        }
                    }
                }
            }
            .refreshable { await carregar(data: dataSelecionada) }
        }
        .task { await carregar() }
        .sheet(isPresented: $mostrarCriar) {
            CriarHabitoSheet { titulo, detalhe, icone, area in
                mostrarCriar = false
                Task {
                    _ = try? await RotinaPlusAPI.criarHabito(
                        titulo: titulo,
                        detalhe: detalhe,
                        icone: icone,
                        area: area
                    )
                    await carregar(data: dataSelecionada)
                }
            } onCancelar: {
                mostrarCriar = false
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $itemNota) { item in
            NotaHabitoSheet(
                item: item,
                data: dataAtual,
                onSalvar: { nota, humor in
                    itemNota = nil
                    Task {
                        _ = try? await RotinaPlusAPI.atualizarHabitoNota(
                            id: item.habito.id,
                            data: dataAtual,
                            nota: nota,
                            humor: humor
                        )
                        await carregar(data: dataSelecionada)
                    }
                },
                onCancelar: { itemNota = nil }
            )
            .presentationDetents([.medium])
        }
    }

    @MainActor
    private func carregar(data: String? = nil) async {
        if journal == nil { carregando = true }
        erro = nil
        do {
            let j = try await RotinaPlusAPI.habitos(data: data ?? dataSelecionada)
            journal = j
            if dataSelecionada == nil {
                dataSelecionada = j.data
            }
        } catch {
            erro = error.localizedDescription
        }
        carregando = false
    }

    @MainActor
    private func toggle(_ item: HabitoItemJournalAPI) async {
        do {
            let result = try await RotinaPlusAPI.toggleHabitoCheckin(
                id: item.habito.id,
                data: dataAtual,
                humor: item.checkin?.humor,
                nota: item.checkin?.nota
            )
            if let bonus = result.bonusDia, bonus.completo {
                mensagemBonus = "Dia completo! +\(bonus.moedas) moedas · streak \(bonus.streakDias)🔥"
            }
            await carregar(data: dataSelecionada)
        } catch {
            erro = error.localizedDescription
        }
    }

    @MainActor
    private func criarDeSugestao(_ s: HabitoSugestaoAPI) async {
        _ = try? await RotinaPlusAPI.criarHabito(
            titulo: s.titulo,
            detalhe: s.detalhe,
            icone: s.icone,
            area: s.area
        )
        await carregar(data: dataSelecionada)
    }

    private func abaParaArea(_ area: String) -> AbaFooter? {
        switch area {
        case "academia": return .academia
        case "financas": return .financas
        default: return nil
        }
    }
}

// MARK: - Subviews

private struct ResumoDiarioCard: View {
    let resumo: HabitoJournalResumoAPI

    var body: some View {
        HStack(spacing: 10) {
            stat(icone: "flame.fill", cor: CoresDiario.streak, valor: "\(resumo.streakGeral)", label: "STREAK")
            stat(icone: "checkmark.circle.fill", cor: CoresDiario.verde, valor: "\(resumo.concluidos)/\(resumo.total)", label: "HOJE")
            stat(icone: "sparkles", cor: CoresDiario.primario, valor: "+\(resumo.xpHoje)", label: "XP")
        }
    }

    private func stat(icone: String, cor: Color, valor: String, label: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icone)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(cor)
            Text(valor)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(CoresDiario.label)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 18).fill(CoresDiario.card))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(CoresDiario.borda, lineWidth: 1))
    }
}

private struct SemanaHeatmapView: View {
    let semana: [HabitoSemanaDiaAPI]
    let selecionada: String
    let hoje: String
    var onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ÚLTIMOS 7 DIAS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(CoresDiario.label)

            HStack(spacing: 6) {
                ForEach(semana) { dia in
                    Button {
                        onSelect(dia.data)
                    } label: {
                        VStack(spacing: 8) {
                            Text(dia.label.uppercased())
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(dia.data == selecionada ? .white : CoresDiario.label)

                            ZStack {
                                Circle()
                                    .fill(fillCor(dia))
                                    .frame(width: 34, height: 34)
                                if dia.percentual == 100 && dia.total > 0 {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                } else {
                                    Text("\(dia.concluidos)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.85))
                                }
                            }

                            if dia.data == hoje {
                                Circle()
                                    .fill(CoresDiario.primario)
                                    .frame(width: 4, height: 4)
                            } else {
                                Color.clear.frame(width: 4, height: 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(dia.data == selecionada ? CoresDiario.primario.opacity(0.22) : Color.white.opacity(0.02))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    dia.data == selecionada ? CoresDiario.primario.opacity(0.55) : CoresDiario.borda,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20).fill(CoresDiario.card))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(CoresDiario.borda, lineWidth: 1))
    }

    private func fillCor(_ dia: HabitoSemanaDiaAPI) -> Color {
        if dia.total == 0 { return Color.white.opacity(0.06) }
        if dia.percentual == 100 { return CoresDiario.verde }
        if dia.percentual >= 50 { return CoresDiario.primario.opacity(0.7) }
        if dia.percentual > 0 { return CoresDiario.primario.opacity(0.35) }
        return Color.white.opacity(0.08)
    }
}

private struct HabitoJournalRow: View {
    let item: HabitoItemJournalAPI
    var onToggle: () -> Void
    var onNota: () -> Void
    var onArea: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(item.concluida ? CoresDiario.verde : Color.white.opacity(0.08))
                        .frame(width: 40, height: 40)
                    if item.concluida {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Text(item.habito.icone)
                            .font(.system(size: 18))
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.habito.titulo)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(item.concluida ? .white.opacity(0.45) : .white)
                    .strikethrough(item.concluida)

                HStack(spacing: 8) {
                    Button(action: onArea) {
                        Text(AreaHabito.label(item.habito.area))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AreaHabito.cor(item.habito.area))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(AreaHabito.cor(item.habito.area).opacity(0.18)))
                    }
                    .buttonStyle(.plain)

                    if item.streak > 0 {
                        Text("🔥 \(item.streak)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(CoresDiario.streak)
                    }

                    Text("+\(item.habito.xp) XP")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(CoresDiario.primario.opacity(0.85))
                }

                if let nota = item.checkin?.nota, !nota.isEmpty {
                    Text(nota)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.45))
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 0)

            Button(action: onNota) {
                Image(systemName: "pencil.and.list.clipboard")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white.opacity(0.06)))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(item.concluida ? Color(red: 0.06, green: 0.12, blue: 0.09) : CoresDiario.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    item.concluida ? CoresDiario.verde.opacity(0.55) : CoresDiario.borda,
                    lineWidth: item.concluida ? 1.5 : 1
                )
        )
    }
}

private struct EmptyHabitosView: View {
    let sugestoes: [HabitoSugestaoAPI]
    var onSugestao: (HabitoSugestaoAPI) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nenhum hábito ainda. Escolha um para começar:")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.55))

            ForEach(Array(sugestoes.prefix(6).enumerated()), id: \.offset) { _, s in
                Button {
                    onSugestao(s)
                } label: {
                    HStack(spacing: 12) {
                        Text(s.icone).font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(s.titulo)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                            Text(s.detalhe)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.45))
                        }
                        Spacer()
                        Text("+")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(CoresDiario.primario)
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(CoresDiario.card))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(CoresDiario.borda, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct CriarHabitoSheet: View {
    var onSalvar: (String, String?, String, String) -> Void
    var onCancelar: () -> Void

    @State private var titulo = ""
    @State private var detalhe = ""
    @State private var icone = "✨"
    @State private var area = "geral"

    private let icones = ["✨", "💧", "🏃", "📚", "💰", "🧘", "✍️", "😴", "📵", "🥗"]
    private let areas = ["geral", "academia", "financas", "estudos", "bemestar"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Hábito") {
                    TextField("Título", text: $titulo)
                    TextField("Detalhe (opcional)", text: $detalhe)
                }
                Section("Ícone") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5)) {
                        ForEach(icones, id: \.self) { i in
                            Button {
                                icone = i
                            } label: {
                                Text(i)
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(i == icone ? CoresDiario.primario.opacity(0.3) : Color.clear))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                Section("Área do app") {
                    Picker("Área", selection: $area) {
                        ForEach(areas, id: \.self) { a in
                            Text(AreaHabito.label(a)).tag(a)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Novo hábito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", action: onCancelar)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        let t = titulo.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard t.count >= 2 else { return }
                        let d = detalhe.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSalvar(t, d.isEmpty ? nil : d, icone, area)
                    }
                    .disabled(titulo.trimmingCharacters(in: .whitespacesAndNewlines).count < 2)
                }
            }
        }
    }
}

private struct NotaHabitoSheet: View {
    let item: HabitoItemJournalAPI
    let data: String
    var onSalvar: (String?, Int?) -> Void
    var onCancelar: () -> Void

    @State private var nota: String = ""
    @State private var humor: Int = 3

    private let humores = ["😞", "😕", "😐", "🙂", "😄"]

    var body: some View {
        NavigationStack {
            Form {
                Section("\(item.habito.icone) \(item.habito.titulo)") {
                    Text("Como foi?").font(.subheadline)
                    HStack {
                        ForEach(1...5, id: \.self) { h in
                            Button {
                                humor = h
                            } label: {
                                Text(humores[h - 1])
                                    .font(.title)
                                    .opacity(humor == h ? 1 : 0.35)
                                    .scaleEffect(humor == h ? 1.15 : 1)
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    TextField("Nota do diário…", text: $nota, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar", action: onCancelar)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        let n = nota.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSalvar(n.isEmpty ? nil : n, humor)
                    }
                }
            }
            .onAppear {
                nota = item.checkin?.nota ?? ""
                humor = item.checkin?.humor ?? 3
            }
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.039, green: 0.031, blue: 0.024).ignoresSafeArea()
        TelaDiarioHabitos()
    }
    .preferredColorScheme(.dark)
}
