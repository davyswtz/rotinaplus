import SwiftUI

// MARK: - Novo treino

struct TelaNovoTreino: View {
    var treinoExistente: AcademiaTreinoAPI? = nil
    var onFechar: () -> Void
    var onSalvo: () -> Void

    @State private var focos: [String] = ["Peito", "Costas", "Ombros", "Braços", "Pernas", "Cardio", "Full body"]
    @State private var foco = "Peito"
    @State private var titulo = ""
    @State private var minutosTexto = "45"
    @State private var catalogo: [ExercicioCatalogoAPI] = []
    @State private var selecionados: [ExercicioDraft] = []
    @State private var salvando = false
    @State private var erro: String?
    @State private var carregando = true

    private let cores = CoresTreinoUI.self

    var body: some View {
        NavigationStack {
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

                if carregando {
                    ProgressView().tint(.white)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            secaoFoco
                            secaoTitulo
                            secaoSelecionados
                            secaoCatalogo
                        }
                        .padding(16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Novo treino")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar", action: onFechar)
                        .foregroundStyle(.white.opacity(0.7))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(salvando ? "..." : "Salvar") {
                        Task { await salvar() }
                    }
                    .disabled(salvando || selecionados.isEmpty)
                    .foregroundStyle(cores.laranja)
                    .fontWeight(.semibold)
                }
            }
            .alert("Erro", isPresented: Binding(
                get: { erro != nil },
                set: { if !$0 { erro = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(erro ?? "")
            }
        }
        .preferredColorScheme(.dark)
        .task { await carregar() }
    }

    private var secaoFoco: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FOCO")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.42))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(focos, id: \.self) { item in
                        Button {
                            foco = item
                            Task { await carregarCatalogo() }
                        } label: {
                            Text(item)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(foco == item ? .white : .white.opacity(0.55))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(
                                    Capsule().fill(foco == item ? cores.primario.opacity(0.35) : Color.white.opacity(0.06))
                                )
                                .overlay(
                                    Capsule().stroke(foco == item ? cores.primario : Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var secaoTitulo: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Título (opcional)", text: $titulo)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.06)))
                .foregroundStyle(.white)

            HStack {
                Text("Duração (min)")
                    .foregroundStyle(.white.opacity(0.55))
                Spacer()
                TextField("45", text: $minutosTexto)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .foregroundStyle(.white)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.06)))
        }
    }

    private var secaoSelecionados: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SEU TREINO (\(selecionados.count))")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.42))

            if selecionados.isEmpty {
                Text("Toque nos exercícios abaixo para montar o treino.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.vertical, 8)
            } else {
                ForEach($selecionados) { $item in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(item.icone).font(.title3)
                            Text(item.nome)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                            Spacer()
                            Button {
                                selecionados.removeAll { $0.id == item.id }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.white.opacity(0.35))
                            }
                        }
                        HStack(spacing: 12) {
                            stepper("Séries", value: $item.series, range: 1...10)
                            stepper("Reps", value: $item.reps, range: 1...50)
                            stepper("Kg", value: $item.cargaKg, range: 0...300)
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.05)))
                }
            }
        }
    }

    private var secaoCatalogo: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BIBLIOTECA")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.42))

            ForEach(catalogo) { ex in
                Button {
                    adicionar(ex)
                } label: {
                    HStack(spacing: 12) {
                        Text(ex.icone).font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ex.nome)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("\(ex.seriesPadrao)×\(ex.repsPadrao) · \(ex.cargaPadrao) kg")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(cores.laranja)
                            .font(.title3)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.04)))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func stepper(_ label: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
            HStack(spacing: 8) {
                Button("-") {
                    value.wrappedValue = max(range.lowerBound, value.wrappedValue - 1)
                }
                .foregroundStyle(.white.opacity(0.7))
                Text("\(value.wrappedValue)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .frame(minWidth: 24)
                Button("+") {
                    value.wrappedValue = min(range.upperBound, value.wrappedValue + 1)
                }
                .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.04)))
    }

    private func adicionar(_ ex: ExercicioCatalogoAPI) {
        if selecionados.contains(where: { $0.chave == ex.chave }) { return }
        selecionados.append(
            ExercicioDraft(
                chave: ex.chave,
                nome: ex.nome,
                icone: ex.icone,
                series: ex.seriesPadrao,
                reps: ex.repsPadrao,
                cargaKg: ex.cargaPadrao
            )
        )
    }

    @MainActor
    private func carregar() async {
        carregando = true
        if let existente = treinoExistente {
            foco = existente.foco
            titulo = existente.titulo
            minutosTexto = "\(existente.minutos)"
            selecionados = (existente.itens ?? []).map {
                ExercicioDraft(
                    chave: $0.exercicioChave,
                    nome: $0.nome,
                    icone: $0.icone,
                    series: $0.series,
                    reps: $0.reps,
                    cargaKg: $0.cargaKg
                )
            }
        }
        do {
            let data = try await RotinaPlusAPI.catalogoExercicios(grupo: foco)
            focos = data.focos.isEmpty ? focos : data.focos
            catalogo = data.exercicios
        } catch {
            erro = error.localizedDescription
        }
        carregando = false
    }

    @MainActor
    private func carregarCatalogo() async {
        do {
            let data = try await RotinaPlusAPI.catalogoExercicios(grupo: foco)
            catalogo = data.exercicios
        } catch {
            erro = error.localizedDescription
        }
    }

    @MainActor
    private func salvar() async {
        salvando = true
        erro = nil
        do {
            let minutos = Int(minutosTexto) ?? 45
            let payload = selecionados.map {
                TreinoExercicioPayload(
                    exercicioChave: $0.chave,
                    series: $0.series,
                    reps: $0.reps,
                    cargaKg: $0.cargaKg
                )
            }
            _ = try await RotinaPlusAPI.criarTreino(
                foco: foco,
                titulo: titulo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : titulo,
                minutos: minutos,
                exercicios: payload
            )
            onSalvo()
            onFechar()
        } catch {
            erro = error.localizedDescription
        }
        salvando = false
    }
}

private struct ExercicioDraft: Identifiable, Equatable {
    let id = UUID()
    var chave: String
    var nome: String
    var icone: String
    var series: Int
    var reps: Int
    var cargaKg: Int
}

// MARK: - Iniciar treino

struct TelaIniciarTreino: View {
    let treinoId: Int
    var onFechar: () -> Void
    var onConcluido: () -> Void

    @State private var treino: AcademiaTreinoAPI?
    @State private var erro: String?
    @State private var salvando = false

    private let cores = CoresTreinoUI.self

    var body: some View {
        NavigationStack {
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

                if let treino {
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(treino.titulo)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.white)
                                Text("\(treino.foco) · \(treino.exercicios) exercícios · ~\(treino.minutos) min · +\(treino.xp) XP")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.5))

                                ForEach(treino.itens ?? [], id: \.stableId) { item in
                                    Button {
                                        Task { await toggle(item) }
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: (item.concluido ?? false) ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle((item.concluido ?? false) ? cores.verde : .white.opacity(0.3))
                                                .font(.title2)
                                            Text(item.icone)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(item.nome)
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundStyle(.white)
                                                Text("\(item.series)×\(item.reps) · \(item.cargaKg) kg")
                                                    .font(.caption)
                                                    .foregroundStyle(.white.opacity(0.4))
                                            }
                                            Spacer()
                                        }
                                        .padding(14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill((item.concluido ?? false) ? cores.primario.opacity(0.18) : Color.white.opacity(0.04))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(16)
                        }

                        Button {
                            Task { await concluir() }
                        } label: {
                            Text(salvando ? "Salvando..." : "Concluir treino · +\(treino.xp) XP")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(RoundedRectangle(cornerRadius: 16).fill(cores.primario))
                        }
                        .disabled(salvando)
                        .padding(16)
                    }
                } else {
                    ProgressView().tint(.white)
                }
            }
            .navigationTitle("Treino")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar", action: onFechar)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .alert("Erro", isPresented: Binding(
                get: { erro != nil },
                set: { if !$0 { erro = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(erro ?? "")
            }
        }
        .preferredColorScheme(.dark)
        .task { await carregar() }
    }

    @MainActor
    private func carregar() async {
        do {
            treino = try await RotinaPlusAPI.detalheTreino(id: treinoId)
        } catch {
            erro = error.localizedDescription
        }
    }

    @MainActor
    private func toggle(_ item: AcademiaTreinoExercicioAPI) async {
        guard let id = item.id else { return }
        let novoEstado = !(item.concluido ?? false)
        do {
            try await RotinaPlusAPI.toggleTreinoExercicio(
                treinoId: treinoId,
                exercicioId: id,
                concluido: novoEstado
            )
            if let i = treino?.itens?.firstIndex(where: { $0.id == id }) {
                treino!.itens![i].concluido = novoEstado
            }
        } catch {
            erro = error.localizedDescription
        }
    }

    @MainActor
    private func concluir() async {
        salvando = true
        do {
            _ = try await RotinaPlusAPI.concluirTreino(id: treinoId)
            onConcluido()
            onFechar()
        } catch {
            erro = error.localizedDescription
        }
        salvando = false
    }
}

// MARK: - Histórico

struct TelaHistoricoTreinos: View {
    var onFechar: () -> Void
    var onAbrir: (AcademiaTreinoAPI) -> Void = { _ in }

    @State private var treinos: [AcademiaTreinoAPI] = []
    @State private var erro: String?

    var body: some View {
        NavigationStack {
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

                if treinos.isEmpty && erro == nil {
                    Text("Nenhum treino no histórico ainda.")
                        .foregroundStyle(.white.opacity(0.45))
                } else {
                    List {
                        ForEach(treinos) { t in
                            Button {
                                onAbrir(t)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(t.titulo)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text("\(t.foco) · \(t.exercicios) ex. · \(t.minutos) min · +\(t.xp) XP")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.45))
                                    if t.concluidoEm != nil {
                                        Text("Concluído")
                                            .font(.caption2.bold())
                                            .foregroundStyle(CoresTreinoUI.verde)
                                    } else if t.ativo == true {
                                        Text("Ativo")
                                            .font(.caption2.bold())
                                            .foregroundStyle(CoresTreinoUI.laranja)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.white.opacity(0.04))
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Histórico")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar", action: onFechar)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .preferredColorScheme(.dark)
        .task {
            if let cached = OfflineStore.shared.load(
                [AcademiaTreinoAPI].self,
                key: OfflineCacheKey.historicoTreinos.rawValue
            ) {
                treinos = cached
            }
            do {
                treinos = try await RotinaPlusAPI.historicoTreinos()
            } catch {
                if treinos.isEmpty {
                    erro = error.localizedDescription
                }
            }
        }
    }
}

private enum CoresTreinoUI {
    static let primario = Color(red: 0.910, green: 0.471, blue: 0.188)
    static let laranja = Color(red: 1.0, green: 0.608, blue: 0.290)
    static let verde = Color(red: 0.29, green: 0.87, blue: 0.50)
}
