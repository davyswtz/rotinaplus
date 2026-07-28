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
    static let fundo = Color(red: 0.141, green: 0.110, blue: 0.078)
    static let borda = Color(red: 0.910, green: 0.471, blue: 0.188).opacity(0.35)
    static let saudacao = Color.white.opacity(0.55)
    static let classeFundo = Color.white.opacity(0.08)
    static let classeTexto = Color(red: 1.0, green: 0.78, blue: 0.55)
    static let xpTrack = Color.black.opacity(0.35)
    static let xpFill = Color(red: 0.910, green: 0.471, blue: 0.188)
    static let xpTexto = Color.white.opacity(0.45)
    static let nivelCircle = Color(red: 0.910, green: 0.471, blue: 0.188)
    static let glow = Color(red: 0.910, green: 0.471, blue: 0.188).opacity(0.22)
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
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(saudacao)
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(1.0)
                        .foregroundStyle(CoresCardPerfil.saudacao)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text(dados.nomeUsuario.lowercased())
                        .font(.system(size: 26, weight: .bold))
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
                        .frame(width: 80, height: 80)

                    Image(dados.avatarAsset)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFill()
                        .frame(width: 66, height: 66)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1))

                    Image("splash_guara")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .offset(x: 24, y: 32)
                }
                .frame(width: 88, height: 92)
            }

            HStack(spacing: 10) {
                Text("\(dados.nivel)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(CoresCardPerfil.nivelCircle))

                Capsule()
                    .fill(CoresCardPerfil.xpTrack)
                    .frame(height: 8)
                    .overlay(alignment: .leading) {
                        GeometryReader { bar in
                            Capsule()
                                .fill(CoresCardPerfil.xpFill)
                                .frame(width: max(8, bar.size.width * dados.progresso))
                        }
                    }
                    .clipShape(Capsule())

                Text("\(dados.xpAtual)/\(dados.xpProximoNivel)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(CoresCardPerfil.xpTexto)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .layoutPriority(1)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 22).fill(CoresCardPerfil.fundo))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(CoresCardPerfil.borda, lineWidth: 1))
    }
}

#Preview {
    ZStack {
        Color(red: 0.039, green: 0.031, blue: 0.024).ignoresSafeArea()
        CardPerfilHeroi(dados: .preview)
            .padding()
    }
    .preferredColorScheme(.dark)
}
