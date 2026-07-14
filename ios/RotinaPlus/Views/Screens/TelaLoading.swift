import SwiftUI

// MARK: - Cores da splash / loading
private enum CoresLoading {
    static let fundoSuperior = Color(red: 0.05, green: 0.03, blue: 0.09)
    static let fundoInferior = Color(red: 0.04, green: 0.06, blue: 0.06)
    static let tituloInicio = Color(red: 0.67, green: 0.49, blue: 1.0)
    static let tituloFim = Color(red: 0.29, green: 0.91, blue: 0.65)
    static let tagline = Color.white.opacity(0.40)
    static let ponto = Color(red: 0.62, green: 0.45, blue: 0.95)
    static let patinha = Color(red: 1.0, green: 0.55, blue: 0.20)
}

/// Tela de loading / splash exibida na abertura do app.
struct TelaLoading: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CoresLoading.fundoSuperior, CoresLoading.fundoInferior],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Image("splash_guara")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .padding(.bottom, 28)

                Text("Rotina Plus")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [CoresLoading.tituloInicio, CoresLoading.tituloFim],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.bottom, 10)

                Text("GAMIFIQUE SUA VIDA REAL")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .tracking(1.5)
                    .foregroundStyle(CoresLoading.tagline)
                    .padding(.bottom, 36)

                IndicadorLoadingPatinha()

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}

/// Patinha pulsando + 3 pontos animados.
private struct IndicadorLoadingPatinha: View {
    @State private var fase = false

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 28))
                .foregroundStyle(CoresLoading.patinha)
                .scaleEffect(fase ? 1.15 : 0.92)
                .opacity(fase ? 1 : 0.7)
                .animation(
                    .easeInOut(duration: 0.7).repeatForever(autoreverses: true),
                    value: fase
                )

            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { indice in
                    Circle()
                        .fill(CoresLoading.ponto)
                        .frame(width: 8, height: 8)
                        .offset(y: fase ? -5 : 5)
                        .opacity(fase ? 1 : 0.45)
                        .animation(
                            .easeInOut(duration: 0.45)
                                .repeatForever(autoreverses: true)
                                .delay(Double(indice) * 0.15),
                            value: fase
                        )
                }
            }
        }
        .onAppear { fase = true }
    }
}

#Preview {
    TelaLoading()
}
