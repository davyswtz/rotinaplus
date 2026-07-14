import SwiftUI

enum AtalhoRapido: String, CaseIterable, Identifiable {
    case treino
    case financas
    case estudar
    case ranking
    case loja
    case conquistas

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .treino: return "Treino"
        case .financas: return "Finanças"
        case .estudar: return "Estudar"
        case .ranking: return "Ranking"
        case .loja: return "Loja"
        case .conquistas: return "Conquistas"
        }
    }

    var icone: String {
        switch self {
        case .treino: return "🏋️"
        case .financas: return "📊"
        case .estudar: return "📚"
        case .ranking: return "🏆"
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
        default: return nil
        }
    }
}

private enum CoresAtalhos {
    static let titulo = Color.white
    static let label = Color.white.opacity(0.55)
    static let card = Color.white.opacity(0.04)
    static let borda = Color(red: 0.48, green: 0.26, blue: 0.96).opacity(0.28)
    static let mensagem = Color.white.opacity(0.55)
}

/// Grade de atalhos rápidos + card da Fox.
struct AtalhosRapidosView: View {
    var mensagemFox: String = "Bora começar as missões, herói! 🦊"
    var onAtalho: (AtalhoRapido) -> Void = { _ in }

    var body: some View {
        GeometryReader { geo in
            let compacto = LayoutDashboard.isCompacto(geo.size.width)
            let gap: CGFloat = compacto ? 8 : 10
            let colunas = Array(repeating: GridItem(.flexible(), spacing: gap), count: 3)

            VStack(alignment: .leading, spacing: compacto ? 10 : 12) {
                Text("Atalhos rápidos")
                    .font(.system(size: compacto ? 16 : 17, weight: .bold))
                    .foregroundStyle(CoresAtalhos.titulo)

                LazyVGrid(columns: colunas, spacing: gap) {
                    ForEach(AtalhoRapido.allCases) { atalho in
                        Button {
                            onAtalho(atalho)
                        } label: {
                            VStack(spacing: compacto ? 6 : 8) {
                                Text(atalho.icone)
                                    .font(.system(size: compacto ? 22 : 26))
                                Text(atalho.titulo)
                                    .font(.system(size: compacto ? 11 : 12, weight: .medium, design: .monospaced))
                                    .foregroundStyle(CoresAtalhos.label)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, compacto ? 12 : 16)
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
                        .frame(width: compacto ? 40 : 44, height: compacto ? 40 : 44)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Fox diz:")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        Text(mensagemFox)
                            .font(.system(size: compacto ? 12 : 13))
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
            .frame(width: geo.size.width, alignment: .topLeading)
        }
        .frame(minHeight: LayoutDashboard.isCompacto(UIScreen.main.bounds.width) ? 260 : 280)
    }
}

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.03, blue: 0.10).ignoresSafeArea()
        AtalhosRapidosView()
            .padding()
    }
    .preferredColorScheme(.dark)
}
