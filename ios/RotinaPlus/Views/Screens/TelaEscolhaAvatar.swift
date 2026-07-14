import SwiftUI

// MARK: - Cores (mesmo dark purple do onboarding / mock)
private enum CoresEscolhaAvatar {
    static let fundoSuperior = Color(red: 0.10, green: 0.06, blue: 0.18)
    static let fundoInferior = Color(red: 0.05, green: 0.03, blue: 0.10)
    static let roxoPrimario = Color(red: 0.48, green: 0.26, blue: 0.96)
    static let textoSecundario = Color.white.opacity(0.55)
    static let tile = Color.white.opacity(0.06)
    static let tileBorda = Color.white.opacity(0.08)
    static let barraInativa = Color.white.opacity(0.12)
}

/// Ícones da coleção do explorador ( Assets.xcassets ).
enum AvatarExplorador: String, CaseIterable, Identifiable {
    case guaraSerio = "avatar_guara_serio"
    case guaraSorriso = "avatar_guara_sorriso"
    case guaraSono = "avatar_guara_sono"
    case guaraSurpreso = "avatar_guara_surpreso"
    case bussola = "avatar_bussola"
    case mapaEscrevendo = "avatar_mapa_escrevendo"
    case corda = "avatar_corda"
    case lanterna = "avatar_lanterna"
    case mapaTesouro = "avatar_mapa_tesouro"
    case clava = "avatar_clava"
    case pergaminho = "avatar_pergaminho"
    case bolsaMoedas = "avatar_bolsa_moedas"
    case emblemaClavas = "avatar_emblema_clavas"
    case escudo = "avatar_escudo"
    case mapMaker = "avatar_map_maker"
    case selo = "avatar_selo"

    var id: String { rawValue }
}

/// Passo 2 de 3 — seleção de avatar (layout idêntico ao mock).
struct TelaEscolhaAvatar: View {
    var onContinuar: (AvatarExplorador) -> Void = { _ in }
    var onVoltar: () -> Void = {}

    @State private var selecionado: AvatarExplorador = .guaraSerio

    private let colunas = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CoresEscolhaAvatar.fundoSuperior, CoresEscolhaAvatar.fundoInferior],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                barraProgresso
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                Text("PASSO 2 DE 3")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(1.2)
                    .foregroundStyle(CoresEscolhaAvatar.textoSecundario)
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                Text("Escolha seu avatar")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                Text("Sua identidade visual no mundo")
                    .font(.body)
                    .foregroundStyle(CoresEscolhaAvatar.textoSecundario)
                    .padding(.top, 6)
                    .padding(.horizontal, 24)

                LazyVGrid(columns: colunas, spacing: 12) {
                    ForEach(AvatarExplorador.allCases) { avatar in
                        botaoAvatar(avatar)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)

                Spacer(minLength: 16)

                Button {
                    onContinuar(selecionado)
                } label: {
                    Text("Continuar →")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(CoresEscolhaAvatar.roxoPrimario)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)

                Button {
                    onVoltar()
                } label: {
                    Text("← Voltar")
                        .font(.body.weight(.medium))
                        .foregroundStyle(CoresEscolhaAvatar.textoSecundario)
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
                    .fill(indice < 2 ? CoresEscolhaAvatar.roxoPrimario : CoresEscolhaAvatar.barraInativa)
                    .frame(height: 4)
            }
        }
    }

    private func botaoAvatar(_ avatar: AvatarExplorador) -> some View {
        let ativo = selecionado == avatar
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selecionado = avatar
            }
        } label: {
            Image(avatar.rawValue)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .padding(8)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(CoresEscolhaAvatar.tile)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            ativo ? CoresEscolhaAvatar.roxoPrimario : CoresEscolhaAvatar.tileBorda,
                            lineWidth: ativo ? 2.5 : 1
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(avatar.rawValue)
        .accessibilityAddTraits(ativo ? .isSelected : [])
    }
}

#Preview {
    TelaEscolhaAvatar()
}
