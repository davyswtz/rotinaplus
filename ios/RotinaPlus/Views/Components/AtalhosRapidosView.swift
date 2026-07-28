import SwiftUI

enum AtalhoRapido: String, CaseIterable, Identifiable {
    case treino
    case financas
    case estudar
    case diario
    case loja
    case conquistas

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .treino: return "Treino"
        case .financas: return "Finanças"
        case .estudar: return "Estudos"
        case .diario: return "Diário"
        case .loja: return "Loja"
        case .conquistas: return "Conquistas"
        }
    }

    var icone: String {
        switch self {
        case .treino: return "🏋️"
        case .financas: return "📊"
        case .estudar: return "📚"
        case .diario: return "📓"
        case .loja: return "🛒"
        case .conquistas: return "🎯"
        }
    }

    /// Aba do footer correspondente, quando existir.
    var abaDestino: AbaFooter? {
        switch self {
        case .treino: return .academia
        case .financas: return .financas
        case .estudar: return .estudos
        case .diario: return .diario
        default: return nil
        }
    }
}

private enum CoresAtalhos {
    static let titulo = Color.white
    static let label = Color.white.opacity(0.55)
    static let card = Color.white.opacity(0.04)
    static let borda = Color(red: 0.910, green: 0.471, blue: 0.188).opacity(0.28)
    static let mensagem = Color.white.opacity(0.55)
}

/// Grade de atalhos rápidos + card da Fox.
struct AtalhosRapidosView: View {
    var mensagemFox: String = "Bora começar as missões, herói! 🦊"
    var onAtalho: (AtalhoRapido) -> Void = { _ in }

    private let gap: CGFloat = 10
    private let colunas = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Atalhos rápidos")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(CoresAtalhos.titulo)

            LazyVGrid(columns: colunas, spacing: gap) {
                ForEach(AtalhoRapido.allCases) { atalho in
                    Button {
                        onAtalho(atalho)
                    } label: {
                        VStack(spacing: 8) {
                            Text(atalho.icone)
                                .font(.system(size: 24))
                            Text(atalho.titulo)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(CoresAtalhos.label)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 16).fill(CoresAtalhos.card))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(CoresAtalhos.borda, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 12) {
                Image("splash_guara")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Fox diz:")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                    Text(mensagemFox)
                        .font(.system(size: 13))
                        .foregroundStyle(CoresAtalhos.mensagem)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 20).fill(CoresAtalhos.card))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(CoresAtalhos.borda, lineWidth: 1))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ZStack {
        Color(red: 0.039, green: 0.031, blue: 0.024).ignoresSafeArea()
        AtalhosRapidosView()
            .padding()
    }
    .preferredColorScheme(.dark)
}
