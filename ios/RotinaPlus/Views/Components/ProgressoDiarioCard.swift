import SwiftUI

struct DadosProgressoDiario: Equatable {
    var concluidos: Int
    var total: Int

    var fracao: Double {
        guard total > 0 else { return 0 }
        return min(1, Double(concluidos) / Double(total))
    }

    var percentual: Int {
        Int((fracao * 100).rounded())
    }

    static let preview = DadosProgressoDiario(concluidos: 1, total: 4)
}

private enum CoresProgressoDiario {
    static let fundo = Color.white.opacity(0.04)
    static let borda = Color(red: 0.48, green: 0.26, blue: 0.96).opacity(0.28)
    static let label = Color(red: 0.72, green: 0.62, blue: 0.92)
    static let percentual = Color(red: 0.45, green: 0.95, blue: 0.55)
    static let track = Color.white.opacity(0.08)
    static let fill = Color(red: 0.48, green: 0.26, blue: 0.96)
}

/// Card de progresso diário das tarefas/hábitos.
struct ProgressoDiarioCard: View {
    let dados: DadosProgressoDiario

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("PROGRESSO DIÁRIO")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(CoresProgressoDiario.label)

                Spacer()

                Text("\(dados.percentual)%")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(CoresProgressoDiario.percentual)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CoresProgressoDiario.track)

                    Capsule()
                        .fill(CoresProgressoDiario.fill)
                        .frame(width: max(dados.fracao > 0 ? 10 : 0, geo.size.width * dados.fracao))
                }
            }
            .frame(height: 10)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(CoresProgressoDiario.fundo)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(CoresProgressoDiario.borda, lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.03, blue: 0.10).ignoresSafeArea()
        ProgressoDiarioCard(dados: .preview)
            .padding()
    }
    .preferredColorScheme(.dark)
}
