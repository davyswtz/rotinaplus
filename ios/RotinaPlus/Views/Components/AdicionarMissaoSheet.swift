import SwiftUI

/// Sheet para criar uma missão do dia (XP calculado no servidor).
struct AdicionarMissaoSheet: View {
    var onSalvar: (String, String, String) async throws -> Void
    var onCancelar: () -> Void

    @State private var titulo = ""
    @State private var detalhe = ""
    @State private var icone = "🎯"
    @State private var salvando = false
    @State private var erro: String?

    private let icones = ["⚔️", "💧", "🏃", "📚", "🧘", "💰", "🔥", "🦊", "📖", "🎯"]

    private var podeSalvar: Bool {
        !titulo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !salvando
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.03, blue: 0.10).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Ícone")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.55))

                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible()), count: 5),
                            spacing: 10
                        ) {
                            ForEach(icones, id: \.self) { emoji in
                                Button {
                                    icone = emoji
                                } label: {
                                    Text(emoji)
                                        .font(.system(size: 28))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.06))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    icone == emoji
                                                        ? Color(red: 0.48, green: 0.26, blue: 0.96)
                                                        : Color.white.opacity(0.1),
                                                    lineWidth: icone == emoji ? 2 : 1
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        campo(rotulo: "Título", placeholder: "Ex: Beber água") {
                            TextField("Ex: Beber água", text: $titulo)
                        }

                        campo(rotulo: "Detalhe (opcional)", placeholder: "Ex: 2L ao longo do dia") {
                            TextField("Ex: 2L ao longo do dia", text: $detalhe)
                        }

                        Text("O XP é calculado automaticamente com base no seu nível — quanto maior o desafio descrito, maior a recompensa justa.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                            .fixedSize(horizontal: false, vertical: true)

                        if let erro {
                            Text(erro)
                                .font(.subheadline)
                                .foregroundStyle(Color(red: 1, green: 0.27, blue: 0.23))
                        }

                        Button {
                            Task { await salvar() }
                        } label: {
                            HStack {
                                if salvando {
                                    ProgressView().tint(.white)
                                }
                                Text(salvando ? "Salvando..." : "Criar missão")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                podeSalvar
                                    ? Color(red: 0.48, green: 0.26, blue: 0.96)
                                    : Color(red: 0.48, green: 0.26, blue: 0.96).opacity(0.45)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!podeSalvar)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Nova missão")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { onCancelar() }
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private func campo<Content: View>(
        rotulo: String,
        placeholder: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(rotulo)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.55))

            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @MainActor
    private func salvar() async {
        let tituloLimpo = titulo.trimmingCharacters(in: .whitespacesAndNewlines)
        let detalheLimpo = detalhe.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tituloLimpo.isEmpty else { return }

        salvando = true
        erro = nil
        do {
            try await onSalvar(
                tituloLimpo,
                detalheLimpo.isEmpty ? "" : detalheLimpo,
                icone
            )
        } catch {
            erro = error.localizedDescription
            salvando = false
        }
    }
}
