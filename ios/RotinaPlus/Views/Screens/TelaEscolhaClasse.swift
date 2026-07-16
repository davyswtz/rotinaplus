import SwiftUI

// MARK: - Catálogo de classes (espelha GET /api/v1/classes)
enum ClasseHeroi: String, CaseIterable, Identifiable, Hashable {
    case guerreiro
    case estudioso
    case investidor
    case sabio

    var id: String { rawValue }

    var nome: String {
        switch self {
        case .guerreiro: return "Guerreiro"
        case .estudioso: return "Estudioso"
        case .investidor: return "Investidor"
        case .sabio: return "Sábio"
        }
    }

    var emoji: String {
        switch self {
        case .guerreiro: return "⚔️"
        case .estudioso: return "📚"
        case .investidor: return "💰"
        case .sabio: return "🔮"
        }
    }

    var descricao: String {
        switch self {
        case .guerreiro: return "Foco em treinos e disciplina física"
        case .estudioso: return "Domina conhecimento e aprendizado"
        case .investidor: return "Mestre das finanças e crescimento"
        case .sabio: return "Equilibra todas as áreas da vida"
        }
    }

    var bonus: [String] {
        switch self {
        case .guerreiro:
            return ["+20% XP na academia", "Streak bônus x2", "Resistência lendária"]
        case .estudioso:
            return ["+20% XP nos estudos", "Memória aprimorada", "Foco sobrenatural"]
        case .investidor:
            return ["+20% XP em finanças", "Renda passiva bônus", "Visão de mercado"]
        case .sabio:
            return ["+10% XP em tudo", "Bônus de equilíbrio", "Sabedoria ancestral"]
        }
    }

    /// Cor dos chips de bônus (mock).
    var corBonus: Color {
        switch self {
        case .guerreiro: return Color(red: 1.0, green: 0.48, blue: 0.28)
        case .estudioso: return Color(red: 0.35, green: 0.85, blue: 0.92)
        case .investidor: return Color(red: 0.35, green: 0.86, blue: 0.52)
        case .sabio: return Color(red: 0.72, green: 0.55, blue: 0.98)
        }
    }
}

// MARK: - Cores
private enum CoresEscolhaClasse {
    static let fundoSuperior = Color(red: 0.10, green: 0.06, blue: 0.18)
    static let fundoInferior = Color(red: 0.05, green: 0.03, blue: 0.10)
    static let roxoPrimario = Color(red: 0.48, green: 0.26, blue: 0.96)
    static let textoSecundario = Color.white.opacity(0.55)
    static let cardFundo = Color.white.opacity(0.06)
    static let cardBorda = Color.white.opacity(0.10)
    static let barraInativa = Color.white.opacity(0.12)
}

/// Passo 1 de 3 — escolha de classe (antes do avatar).
struct TelaEscolhaClasse: View {
    var onContinuar: (ClasseHeroi) -> Void = { _ in }
    var onVoltar: () -> Void = {}

    @State private var selecionada: ClasseHeroi = .guerreiro

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

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(ClasseHeroi.allCases) { classe in
                            cartaoClasse(classe)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                }

                Button {
                    onContinuar(selecionada)
                } label: {
                    Text("Continuar →")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(CoresEscolhaClasse.roxoPrimario)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
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
        .preferredColorScheme(.dark)
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
}

/// Tags de bônus em linha com wrap simples.
private struct FlowBonusTags: View {
    let tags: [String]
    let cor: Color

    var body: some View {
        // Layout em wrap manual (2 linhas típicas no mock).
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
