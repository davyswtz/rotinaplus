import SwiftUI

// MARK: - Catálogo de classes (GET /api/v1/classes)
struct ClasseHeroi: Identifiable, Hashable, Codable {
    let key: String
    let nome: String
    let emoji: String
    let descricao: String
    let bonus: [String]
    let tema: String

    var id: String { key }

    var corBonus: Color {
        switch tema {
        case "laranja":
            return Color(red: 1.0, green: 0.48, blue: 0.28)
        case "ciano":
            return Color(red: 0.35, green: 0.85, blue: 0.92)
        case "verde":
            return Color(red: 0.35, green: 0.86, blue: 0.52)
        case "ambar", "roxo":
            return Color(red: 0.910, green: 0.722, blue: 0.416)
        default:
            return Color(red: 0.910, green: 0.471, blue: 0.188)
        }
    }
}

// MARK: - Cores
private enum CoresEscolhaClasse {
    static let fundoSuperior = Color(red: 0.094, green: 0.078, blue: 0.059)
    static let fundoInferior = Color(red: 0.039, green: 0.031, blue: 0.024)
    static let roxoPrimario = Color(red: 0.910, green: 0.471, blue: 0.188)
    static let textoSecundario = Color.white.opacity(0.55)
    static let cardFundo = Color.white.opacity(0.06)
    static let cardBorda = Color.white.opacity(0.10)
    static let barraInativa = Color.white.opacity(0.12)
}

/// Passo 1 de 3 — escolha de classe (antes do avatar).
struct TelaEscolhaClasse: View {
    var onContinuar: (ClasseHeroi) -> Void = { _ in }
    var onVoltar: () -> Void = {}

    @State private var classes: [ClasseHeroi] = []
    @State private var selecionada: ClasseHeroi?
    @State private var carregando = true
    @State private var erro: String?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CoresEscolhaClasse.fundoSuperior, CoresEscolhaClasse.fundoInferior],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                barraProgresso
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                Text("PASSO 1 DE 3")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(1.2)
                    .foregroundStyle(CoresEscolhaClasse.textoSecundario)
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                Text("Escolha sua classe")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                Text("Define seus bônus iniciais e estilo de jogo")
                    .font(.body)
                    .foregroundStyle(CoresEscolhaClasse.textoSecundario)
                    .padding(.top, 6)
                    .padding(.horizontal, 24)

                if carregando {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    Spacer()
                } else if let erro {
                    Text(erro)
                        .foregroundStyle(.white.opacity(0.65))
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                    Button("Tentar de novo") {
                        Task { await carregarClasses() }
                    }
                    .foregroundStyle(CoresEscolhaClasse.roxoPrimario)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(classes) { classe in
                                cartaoClasse(classe)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                    }

                    Button {
                        if let selecionada {
                            onContinuar(selecionada)
                        }
                    } label: {
                        Text("Continuar →")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                selecionada == nil
                                    ? CoresEscolhaClasse.roxoPrimario.opacity(0.45)
                                    : CoresEscolhaClasse.roxoPrimario
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(selecionada == nil)
                    .padding(.horizontal, 24)

                    Button {
                        onVoltar()
                    } label: {
                        Text("← Voltar")
                            .font(.body.weight(.medium))
                            .foregroundStyle(CoresEscolhaClasse.textoSecundario)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        .preferredColorScheme(.dark)
        .task { await carregarClasses() }
    }

    private var barraProgresso: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { indice in
                Capsule()
                    .fill(indice < 1 ? CoresEscolhaClasse.roxoPrimario : CoresEscolhaClasse.barraInativa)
                    .frame(height: 4)
            }
        }
    }

    private func cartaoClasse(_ classe: ClasseHeroi) -> some View {
        let ativo = selecionada == classe
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selecionada = classe
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 14) {
                    Text(classe.emoji)
                        .font(.system(size: 36))
                        .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(classe.nome)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)

                        Text(classe.descricao)
                            .font(.subheadline)
                            .foregroundStyle(CoresEscolhaClasse.textoSecundario)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: 0)
                }

                FlowBonusTags(tags: classe.bonus, cor: classe.corBonus)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(CoresEscolhaClasse.cardFundo)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        ativo ? CoresEscolhaClasse.roxoPrimario : CoresEscolhaClasse.cardBorda,
                        lineWidth: ativo ? 2.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(classe.nome)
        .accessibilityAddTraits(ativo ? .isSelected : [])
    }

    @MainActor
    private func carregarClasses() async {
        if let cached = OfflineStore.shared.load([ClasseHeroi].self, key: OfflineCacheKey.classes.rawValue) {
            classes = cached
            if selecionada == nil {
                selecionada = cached.first
            }
            carregando = false
        } else {
            carregando = true
        }
        erro = nil
        do {
            let lista = try await RotinaPlusAPI.classes()
            classes = lista
            if selecionada == nil {
                selecionada = lista.first
            }
        } catch {
            if classes.isEmpty {
                self.erro = error.localizedDescription
            }
        }
        carregando = false
    }
}

/// Tags de bônus em linha com wrap simples.
private struct FlowBonusTags: View {
    let tags: [String]
    let cor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(Array(tags.prefix(2).enumerated()), id: \.offset) { _, tag in
                    tagView(tag)
                }
            }
            if tags.count > 2 {
                HStack(spacing: 8) {
                    ForEach(Array(tags.dropFirst(2).enumerated()), id: \.offset) { _, tag in
                        tagView(tag)
                    }
                }
            }
        }
    }

    private func tagView(_ texto: String) -> some View {
        Text(texto)
            .font(.caption.weight(.semibold))
            .foregroundStyle(cor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(cor.opacity(0.18))
            )
    }
}

#Preview {
    TelaEscolhaClasse()
}
