import SwiftUI

struct DadosCardPerfil: Equatable {
    var nomeUsuario: String
    var classe: String
    var emojiClasse: String
    var nivel: Int
    var xpAtual: Int
    var xpProximoNivel: Int
    var avatarAsset: String

    var progresso: Double {
        guard xpProximoNivel > 0 else { return 0 }
        return min(1, Double(xpAtual) / Double(xpProximoNivel))
    }

    static let preview = DadosCardPerfil(
        nomeUsuario: "davy",
        classe: "Sábio",
        emojiClasse: "🔮",
        nivel: 1,
        xpAtual: 240,
        xpProximoNivel: 500,
        avatarAsset: "avatar_guara_sorriso"
    )
}

private enum CoresCardPerfil {
    static let fundo = Color(red: 0.14, green: 0.09, blue: 0.26)
    static let borda = Color(red: 0.48, green: 0.26, blue: 0.96).opacity(0.35)
    static let saudacao = Color.white.opacity(0.55)
    static let classeFundo = Color.white.opacity(0.08)
    static let classeTexto = Color(red: 0.72, green: 0.58, blue: 1.0)
    static let xpTrack = Color.black.opacity(0.35)
    static let xpFill = Color(red: 0.48, green: 0.26, blue: 0.96)
    static let xpTexto = Color.white.opacity(0.45)
    static let nivelCircle = Color(red: 0.48, green: 0.26, blue: 0.96)
    static let glow = Color(red: 0.48, green: 0.26, blue: 0.96).opacity(0.22)
}

/// Card de resumo do herói (abaixo do header no dashboard).
struct CardPerfilHeroi: View {
    let dados: DadosCardPerfil

    private var saudacao: String {
        let hora = Calendar.current.component(.hour, from: Date())
        switch hora {
        case 5..<12: return "BOM DIA, HERÓI"
        case 12..<18: return "BOA TARDE, HERÓI"
        default: return "BOA NOITE, HERÓI"
        }
    }

    var body: some View {
        GeometryReader { geo in
            let compacto = LayoutDashboard.isCompacto(geo.size.width)
            let avatar: CGFloat = compacto ? 60 : 72
            let glow: CGFloat = compacto ? 76 : 88

            VStack(alignment: .leading, spacing: compacto ? 14 : 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(saudacao)
                            .font(.system(size: compacto ? 10 : 11, weight: .semibold))
                            .tracking(compacto ? 0.6 : 1.1)
                            .foregroundStyle(CoresCardPerfil.saudacao)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text(dados.nomeUsuario.lowercased())
                            .font(.system(size: compacto ? 24 : 28, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        HStack(spacing: 6) {
                            Text(dados.emojiClasse)
                                .font(.system(size: 12))
                            Text(dados.classe)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(CoresCardPerfil.classeTexto)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(CoresCardPerfil.classeFundo))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    ZStack {
                        Circle()
                            .fill(CoresCardPerfil.glow)
                            .frame(width: glow, height: glow)

                        Image(dados.avatarAsset)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFill()
                            .frame(width: avatar, height: avatar)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1))

                        Image("splash_guara")
                            .resizable()
                            .scaledToFit()
                            .frame(width: compacto ? 24 : 28, height: compacto ? 24 : 28)
                            .offset(x: avatar * 0.36, y: avatar * 0.48)
                    }
                    .frame(width: glow + 8, height: glow + 12)
                }

                HStack(spacing: 10) {
                    Text("\(dados.nivel)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(CoresCardPerfil.nivelCircle))

                    GeometryReader { bar in
                        ZStack(alignment: .leading) {
                            Capsule().fill(CoresCardPerfil.xpTrack)
                            Capsule()
                                .fill(CoresCardPerfil.xpFill)
                                .frame(width: max(8, bar.size.width * dados.progresso))
                        }
                    }
                    .frame(height: 8)

                    Text("\(dados.xpAtual)/\(dados.xpProximoNivel)")
                        .font(.system(size: compacto ? 11 : 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(CoresCardPerfil.xpTexto)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .layoutPriority(1)
                }
            }
            .padding(compacto ? 14 : 18)
            .background(RoundedRectangle(cornerRadius: 22).fill(CoresCardPerfil.fundo))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(CoresCardPerfil.borda, lineWidth: 1))
            .frame(width: geo.size.width)
        }
        .frame(minHeight: LayoutDashboard.isCompacto(UIScreen.main.bounds.width) ? 168 : 188)
    }
}

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.03, blue: 0.10).ignoresSafeArea()
        CardPerfilHeroi(dados: .preview)
            .padding()
    }
    .preferredColorScheme(.dark)
}
