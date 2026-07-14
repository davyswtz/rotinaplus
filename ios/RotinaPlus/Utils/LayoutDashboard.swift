import SwiftUI

/// Métricas responsivas compartilhadas pelo dashboard.
enum LayoutDashboard {
    /// Padding horizontal padrão conforme largura.
    static func paddingHorizontal(_ largura: CGFloat) -> CGFloat {
        switch largura {
        case ..<340: return 12
        case ..<390: return 14
        case ..<430: return 16
        default: return 20
        }
    }

    /// Espaçamento vertical entre blocos.
    static func gapSecao(_ largura: CGFloat) -> CGFloat {
        largura < 360 ? 10 : 12
    }

    static func isCompacto(_ largura: CGFloat) -> Bool {
        largura < 360
    }

    static func isEstreito(_ largura: CGFloat) -> Bool {
        largura < 340
    }
}

/// Wrapper que injeta a largura disponível no conteúdo.
struct LarguraDashboard<Content: View>: View {
    @ViewBuilder var content: (CGFloat) -> Content

    var body: some View {
        GeometryReader { geo in
            content(geo.size.width)
                .frame(width: geo.size.width, alignment: .top)
        }
    }
}
