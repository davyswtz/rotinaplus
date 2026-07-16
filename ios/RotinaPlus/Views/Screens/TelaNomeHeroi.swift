import SwiftUI

// MARK: - Cores (onboarding + acento teal do mock)
private enum CoresNomeHeroi {
    static let fundoSuperior = Color(red: 0.10, green: 0.06, blue: 0.18)
    static let fundoInferior = Color(red: 0.05, green: 0.03, blue: 0.10)
    static let roxoPrimario = Color(red: 0.48, green: 0.26, blue: 0.96)
    static let textoSecundario = Color.white.opacity(0.55)
    static let tile = Color.white.opacity(0.06)
    static let acentoTeal = Color(red: 0.45, green: 0.82, blue: 0.90)
    static let campoFundo = Color.white.opacity(0.08)
    static let campoBorda = Color.white.opacity(0.14)
    static let barraInativa = Color.white.opacity(0.12)
}

extension AvatarExplorador {
    /// Traço exibido no chip abaixo do ícone (passo 3).
    var traco: (emoji: String, nome: String) {
        switch self {
        case .guaraSerio, .guaraSorriso, .guaraSono, .guaraSurpreso:
            return ("🦊", "Explorador")
        case .mapaEscrevendo, .mapaTesouro, .pergaminho, .mapMaker:
            return ("📚", "Estudioso")
        case .bussola, .lanterna, .corda:
            return ("🧭", "Navegador")
        case .clava, .emblemaClavas, .escudo:
            return ("⚔️", "Guerreiro")
        case .bolsaMoedas, .selo:
            return ("🏆", "Colecionador")
        }
    }
}

/// Passo 3 de 3 — nome do herói + preview do avatar escolhido.
struct TelaNomeHeroi: View {
    let avatar: AvatarExplorador
    var classe: ClasseHeroi = .sabio
    var onComecar: (String) async throws -> Void = { _ in }
    var onVoltar: () -> Void = {}

    @State private var nome = ""
    @State private var salvando = false
    @State private var erroSalvar: String?
    @FocusState private var focoNome: Bool

    private let limiteNome = 20

    private var nomeValido: Bool {
        !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CoresNomeHeroi.fundoSuperior, CoresNomeHeroi.fundoInferior],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                barraProgresso
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                Text("PASSO 3 DE 3")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(1.2)
                    .foregroundStyle(CoresNomeHeroi.textoSecundario)
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                Text("Seu nome de herói")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                Text("Como o mundo vai te conhecer")
                    .font(.body)
                    .foregroundStyle(CoresNomeHeroi.textoSecundario)
                    .padding(.top, 6)
                    .padding(.horizontal, 24)

                previewAvatar
                    .padding(.top, 32)

                campoNome
                    .padding(.top, 28)
                    .padding(.horizontal, 24)

                Spacer(minLength: 16)

                if let erroSalvar {
                    Text(erroSalvar)
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 1.0, green: 0.27, blue: 0.23))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                }

                Button {
                    let limpo = nome.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !limpo.isEmpty, !salvando else { return }
                    salvando = true
                    erroSalvar = nil
                    Task {
                        do {
                            try await onComecar(limpo)
                        } catch {
                            erroSalvar = error.localizedDescription
                            salvando = false
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if salvando {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(salvando ? "Salvando herói..." : "Começar aventura 🦊⚡")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        nomeValido && !salvando
                            ? CoresNomeHeroi.roxoPrimario
                            : CoresNomeHeroi.roxoPrimario.opacity(0.45)
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!nomeValido || salvando)
                .padding(.horizontal, 24)

                Button {
                    onVoltar()
                } label: {
                    Text("← Voltar")
                        .font(.body.weight(.medium))
                        .foregroundStyle(CoresNomeHeroi.textoSecundario)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .padding(.bottom, 8)
            }
        }
        .preferredColorScheme(.dark)
        .onTapGesture { focoNome = false }
    }

    private var barraProgresso: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { _ in
                Capsule()
                    .fill(CoresNomeHeroi.roxoPrimario)
                    .frame(height: 4)
            }
        }
    }

    private var previewAvatar: some View {
        VStack(spacing: 14) {
            Image(avatar.rawValue)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .padding(22)
                .frame(width: 148, height: 148)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(CoresNomeHeroi.tile)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(CoresNomeHeroi.acentoTeal.opacity(0.75), lineWidth: 2)
                )

            HStack(spacing: 6) {
                Text(classe.emoji)
                Text(classe.nome)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CoresNomeHeroi.acentoTeal)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.06))
            )
        }
        .frame(maxWidth: .infinity)
    }

    private var campoNome: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOME DO HERÓI")
                .font(.caption)
                .fontWeight(.semibold)
                .tracking(1.0)
                .foregroundStyle(CoresNomeHeroi.textoSecundario)

            TextField("Ex: Arthur, Sora, Neo...", text: $nome)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .focused($focoNome)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .foregroundStyle(.white)
                .tint(CoresNomeHeroi.roxoPrimario)
                .background(CoresNomeHeroi.campoFundo)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(CoresNomeHeroi.campoBorda, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .onChange(of: nome) { novo in
                    if novo.count > limiteNome {
                        nome = String(novo.prefix(limiteNome))
                    }
                }

            Text("\(nome.count)/\(limiteNome)")
                .font(.caption)
                .foregroundStyle(CoresNomeHeroi.textoSecundario)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

#Preview {
    TelaNomeHeroi(avatar: .guaraSorriso, classe: .guerreiro)
}
