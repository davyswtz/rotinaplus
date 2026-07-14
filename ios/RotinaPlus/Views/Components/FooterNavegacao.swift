import SwiftUI

enum AbaFooter: String, CaseIterable, Identifiable {
    case inicio
    case academia
    case financas
    case estudos
    case perfil

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .inicio: return "Início"
        case .academia: return "Academia"
        case .financas: return "Finanças"
        case .estudos: return "Estudos"
        case .perfil: return "Perfil"
        }
    }

    var icone: String {
        switch self {
        case .inicio: return "house"
        case .academia: return "figure.strengthtraining.traditional"
        case .financas: return "creditcard"
        case .estudos: return "book"
        case .perfil: return "person"
        }
    }

    var iconeAtivo: String {
        switch self {
        case .inicio: return "house.fill"
        case .academia: return "figure.strengthtraining.traditional"
        case .financas: return "creditcard.fill"
        case .estudos: return "book.fill"
        case .perfil: return "person.fill"
        }
    }
}

/// Footer de navegação principal do app.
struct FooterNavegacao: View {
    @Binding var abaSelecionada: AbaFooter

    var body: some View {
        GeometryReader { geo in
            let compacto = LayoutDashboard.isCompacto(geo.size.width)
            let pad = LayoutDashboard.paddingHorizontal(geo.size.width)

            HStack(spacing: 0) {
                ForEach(AbaFooter.allCases) { aba in
                    botaoAba(aba, compacto: compacto)
                }
            }
            .padding(.horizontal, compacto ? 4 : 8)
            .padding(.vertical, compacto ? 6 : 8)
            .background(Capsule().fill(CoresFooter.fundo))
            .overlay(Capsule().stroke(CoresFooter.borda, lineWidth: 1))
            .padding(.horizontal, pad)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        .frame(height: 72)
        .padding(.bottom, 4)
    }

    private func botaoAba(_ aba: AbaFooter, compacto: Bool) -> some View {
        let ativo = abaSelecionada == aba
        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                abaSelecionada = aba
            }
        } label: {
            VStack(spacing: 3) {
                Capsule()
                    .fill(ativo ? CoresFooter.ativo : Color.clear)
                    .frame(width: 16, height: 3)

                Image(systemName: ativo ? aba.iconeAtivo : aba.icone)
                    .font(.system(size: compacto ? 14 : 16, weight: .semibold))

                Text(aba.titulo)
                    .font(.system(size: compacto ? 9 : 10, weight: .medium, design: .monospaced))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(ativo ? CoresFooter.ativo : CoresFooter.inativo)
            .frame(maxWidth: .infinity)
            .padding(.vertical, compacto ? 6 : 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(ativo ? CoresFooter.pillAtivo : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(aba.titulo)
        .accessibilityAddTraits(ativo ? .isSelected : [])
    }
}

private enum CoresFooter {
    static let fundo = Color(red: 0.10, green: 0.07, blue: 0.16)
    static let borda = Color(red: 0.48, green: 0.26, blue: 0.96).opacity(0.35)
    static let ativo = Color(red: 0.48, green: 0.26, blue: 0.96)
    static let inativo = Color.white.opacity(0.40)
    static let pillAtivo = Color.white.opacity(0.08)
}
