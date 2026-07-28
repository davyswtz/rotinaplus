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
    static let borda = Color(red: 0.910, green: 0.471, blue: 0.188).opacity(0.28)
    static let label = Color(red: 0.910, green: 0.722, blue: 0.541)
    static let percentual = Color(red: 0.45, green: 0.95, blue: 0.55)
    static let track = Color.white.opacity(0.08)
    static let fill = Color(red: 0.910, green: 0.471, blue: 0.188)
}

/// Card de progresso diário das tarefas/hábitos.
struct ProgressoDiarioCard: View {
    let dados: DadosProgressoDiario

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("PROGRESSO DIÁRIO")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(CoresProgressoDiario.label)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Spacer(minLength: 8)

                Text("\(dados.percentual)%")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(CoresProgressoDiario.percentual)
                    .layoutPriority(1)
            }

            // Barra sem GeometryReader: escala pela fração do espaço disponível.
            Capsule()
                .fill(CoresProgressoDiario.track)
                .frame(height: 10)
                .overlay(alignment: .leading) {
                    GeometryReader { geo in
                        Capsule()
                            .fill(CoresProgressoDiario.fill)
                            .frame(
                                width: max(
                                    dados.fracao > 0 ? 10 : 0,
                                    geo.size.width * dados.fracao
                                )
                            )
                    }
                }
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
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
        Color(red: 0.039, green: 0.031, blue: 0.024).ignoresSafeArea()
        ProgressoDiarioCard(dados: .preview)
            .padding()
    }
    .preferredColorScheme(.dark)
}
