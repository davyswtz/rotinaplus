import SwiftUI

// MARK: - Modelo de dados do header
struct DadosHeaderApp: Equatable {
    var tituloApp: String = "Rotina Plus"
    var nomeUsuario: String
    var nivel: Int
    var streakDias: Int
    var moedas: Int
    var notificacoes: Int
    var avatarAsset: String = "avatar_guara_serio"

    static let preview = DadosHeaderApp(
        nomeUsuario: "davy",
        nivel: 1,
        streakDias: 3,
        moedas: 480,
        notificacoes: 2,
        avatarAsset: "avatar_guara_sorriso"
    )
}

private enum CoresHeader {
    static let titulo = Color.white.opacity(0.88)
    static let subtitulo = Color(red: 0.62, green: 0.42, blue: 0.98)
    static let streakFundo = Color(red: 0.28, green: 0.12, blue: 0.10)
    static let streakTexto = Color(red: 1.0, green: 0.55, blue: 0.28)
    static let moedaFundo = Color(red: 0.28, green: 0.22, blue: 0.10)
    static let moedaTexto = Color(red: 1.0, green: 0.82, blue: 0.28)
    static let sinoFundo = Color.white.opacity(0.08)
    static let badge = Color(red: 0.92, green: 0.22, blue: 0.25)
}

/// Header reutilizável do dashboard e telas principais.
struct HeaderApp: View {
    let dados: DadosHeaderApp
    var onToquePerfil: (() -> Void)?
    var onToqueNotificacoes: (() -> Void)?

    var body: some View {
        GeometryReader { geo in
            let compacto = LayoutDashboard.isCompacto(geo.size.width)
            let estreito = LayoutDashboard.isEstreito(geo.size.width)
            let pad = LayoutDashboard.paddingHorizontal(geo.size.width)

            HStack(alignment: .center, spacing: compacto ? 8 : 12) {
                botaoIdentidade(compacto: compacto)

                Spacer(minLength: 4)

                HStack(spacing: compacto ? 6 : 8) {
                    if !estreito {
                        chip(
                            icone: "flame.fill",
                            texto: "\(dados.streakDias)d",
                            fundo: CoresHeader.streakFundo,
                            cor: CoresHeader.streakTexto,
                            compacto: compacto
                        )
                    }

                    chip(
                        icone: "crown.fill",
                        texto: "\(dados.moedas)",
                        fundo: CoresHeader.moedaFundo,
                        cor: CoresHeader.moedaTexto,
                        compacto: compacto
                    )

                    botaoNotificacoes(compacto: compacto)
                }
                .layoutPriority(1)
            }
            .padding(.horizontal, pad)
            .padding(.vertical, compacto ? 8 : 10)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        .frame(height: 56)
    }

    private func botaoIdentidade(compacto: Bool) -> some View {
        Button {
            onToquePerfil?()
        } label: {
            HStack(spacing: compacto ? 8 : 10) {
                Image(dados.avatarAsset)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFill()
                    .frame(width: compacto ? 32 : 36, height: compacto ? 32 : 36)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(dados.tituloApp)
                        .font(.system(size: compacto ? 13 : 15, weight: .semibold, design: .monospaced))
                        .foregroundStyle(CoresHeader.titulo)
                        .lineLimit(1)

                    Text("\(dados.nomeUsuario) · Lv.\(dados.nivel)")
                        .font(.system(size: compacto ? 11 : 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(CoresHeader.subtitulo)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(dados.tituloApp), \(dados.nomeUsuario), nível \(dados.nivel)")
    }

    private func botaoNotificacoes(compacto: Bool) -> some View {
        let tamanho: CGFloat = compacto ? 32 : 36
        return Button {
            onToqueNotificacoes?()
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                    .font(.system(size: compacto ? 14 : 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: tamanho, height: tamanho)
                    .background(Circle().fill(CoresHeader.sinoFundo))

                if dados.notificacoes > 0 {
                    Text(dados.notificacoes > 9 ? "9+" : "\(dados.notificacoes)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .frame(minWidth: 16, minHeight: 16)
                        .background(Capsule().fill(CoresHeader.badge))
                        .offset(x: 4, y: -3)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Notificações, \(dados.notificacoes)")
    }

    private func chip(icone: String, texto: String, fundo: Color, cor: Color, compacto: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icone)
                .font(.system(size: compacto ? 10 : 11, weight: .semibold))
            Text(texto)
                .font(.system(size: compacto ? 11 : 12, weight: .semibold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(cor)
        .padding(.horizontal, compacto ? 8 : 10)
        .padding(.vertical, compacto ? 6 : 7)
        .background(Capsule().fill(fundo))
    }
}

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.03, blue: 0.10).ignoresSafeArea()
        VStack {
            HeaderApp(dados: .preview)
            Spacer()
        }
    }
    .preferredColorScheme(.dark)
}
