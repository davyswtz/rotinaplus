import SwiftUI

private enum CoresCriacao {
    static let fundoSuperior = Color(red: 0.10, green: 0.06, blue: 0.18)
    static let fundoInferior = Color(red: 0.05, green: 0.03, blue: 0.10)
    static let roxoPrimario = Color(red: 0.48, green: 0.26, blue: 0.96)
    static let laranjaMascote = Color(red: 1.0, green: 0.55, blue: 0.20)
    static let textoSecundario = Color.white.opacity(0.65)
    static let campoFundo = Color.white.opacity(0.08)
    static let campoBorda = Color.white.opacity(0.18)
    static let chipFundo = Color.white.opacity(0.10)
    static let previewFundo = Color.white.opacity(0.06)
    static let selecaoBorda = Color(red: 0.48, green: 0.26, blue: 0.96)
}

struct CriacaoPersonagemView: View {
    @StateObject private var viewModel = CriacaoPersonagemViewModel()
    var onConcluir: (() -> Void)?

    private var assinaturaVisual: String {
        [
            viewModel.genero.rawValue,
            viewModel.corpo.rawValue,
            viewModel.ombros.rawValue,
            viewModel.maos.rawValue,
            viewModel.cabeca.rawValue,
            viewModel.pes.rawValue,
        ].joined(separator: "-")
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CoresCriacao.fundoSuperior, CoresCriacao.fundoInferior],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        cabecalho
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            .padding(.bottom, 12)

                        previewPersonagem
                            .padding(.horizontal, 24)
                            .padding(.bottom, 16)

                        seletorGenero
                            .padding(.horizontal, 24)
                            .padding(.bottom, 14)

                        campoNome
                            .padding(.horizontal, 24)
                            .padding(.bottom, 14)

                        categorias
                            .padding(.bottom, 12)

                        gradeOpcoes
                            .padding(.bottom, 8)
                    }
                }

                botaoConfirmar
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var cabecalho: some View {
        VStack(spacing: 6) {
            Text("Crie seu guará")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("Monte o visual com os conjuntos de couro, placas e robes.")
                .font(.subheadline)
                .foregroundStyle(CoresCriacao.textoSecundario)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var previewPersonagem: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(CoresCriacao.previewFundo)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(CoresCriacao.campoBorda, lineWidth: 1)
                )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            CoresCriacao.roxoPrimario.opacity(0.35),
                            CoresCriacao.laranjaMascote.opacity(0.12),
                            .clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 140
                    )
                )
                .frame(width: 260, height: 260)
                .offset(y: 10)

            PersonagemSpriteView(
                genero: viewModel.genero,
                corpo: viewModel.corpo,
                ombros: viewModel.ombros,
                maos: viewModel.maos,
                cabeca: viewModel.cabeca,
                pes: viewModel.pes
            )
            .frame(maxWidth: 240, maxHeight: 300)
            .padding(.vertical, 8)
            .id(assinaturaVisual)
            .transition(.opacity.combined(with: .scale(scale: 0.96)))
            .animation(.spring(response: 0.35, dampingFraction: 0.82), value: assinaturaVisual)
        }
        .frame(height: 320)
    }

    private var seletorGenero: some View {
        HStack(spacing: 10) {
            ForEach(GeneroPersonagem.allCases) { genero in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.genero = genero
                    }
                } label: {
                    Text(genero.titulo)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            viewModel.genero == genero
                                ? CoresCriacao.roxoPrimario
                                : CoresCriacao.chipFundo
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    viewModel.genero == genero
                                        ? CoresCriacao.selecaoBorda
                                        : CoresCriacao.campoBorda,
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var campoNome: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Nome do personagem")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(CoresCriacao.textoSecundario)
                .padding(.leading, 4)

            TextField("Ex.: Guará, Luna, Kael…", text: $viewModel.nome)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(CoresCriacao.campoFundo)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(CoresCriacao.campoBorda, lineWidth: 1)
                )
                .foregroundStyle(.white)
                .tint(CoresCriacao.roxoPrimario)
        }
    }

    private var categorias: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CriacaoPersonagemViewModel.CategoriaCustomizacao.allCases) { categoria in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.categoriaAtiva = categoria
                        }
                    } label: {
                        Text(categoria.titulo)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                viewModel.categoriaAtiva == categoria
                                    ? CoresCriacao.roxoPrimario.opacity(0.9)
                                    : CoresCriacao.chipFundo
                            )
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var gradeOpcoes: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                switch viewModel.categoriaAtiva {
                case .corpo:
                    ForEach(CorpoPersonagem.allCases) { opcao in
                        cartao(opcao.titulo, opcao.assetThumb, viewModel.corpo == opcao) {
                            viewModel.corpo = opcao
                        }
                    }
                case .cabeca:
                    ForEach(CabecaPersonagem.allCases) { opcao in
                        cartao(opcao.titulo, opcao.assetThumb, viewModel.cabeca == opcao) {
                            viewModel.cabeca = opcao
                        }
                    }
                case .ombros:
                    ForEach(OmbrosPersonagem.allCases) { opcao in
                        cartao(opcao.titulo, opcao.assetThumb, viewModel.ombros == opcao) {
                            viewModel.ombros = opcao
                        }
                    }
                case .maos:
                    ForEach(MaosPersonagem.allCases) { opcao in
                        cartao(opcao.titulo, opcao.assetThumb, viewModel.maos == opcao) {
                            viewModel.maos = opcao
                        }
                    }
                case .pes:
                    ForEach(PesPersonagem.allCases) { opcao in
                        cartao(opcao.titulo, opcao.assetThumb, viewModel.pes == opcao) {
                            viewModel.pes = opcao
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 4)
        }
        .frame(height: 132)
    }

    private func cartao(
        _ titulo: String,
        _ asset: String,
        _ selecionado: Bool,
        acao: @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                acao()
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(CoresCriacao.chipFundo)
                    Image(asset)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .padding(8)
                }
                .frame(width: 88, height: 88)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            selecionado ? CoresCriacao.selecaoBorda : CoresCriacao.campoBorda,
                            lineWidth: selecionado ? 2 : 1
                        )
                )

                Text(titulo)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(selecionado ? .white : CoresCriacao.textoSecundario)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(width: 88)
        }
        .buttonStyle(.plain)
    }

    private var botaoConfirmar: some View {
        Button {
            if viewModel.salvar() != nil {
                onConcluir?()
            }
        } label: {
            Text("Começar aventura")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    viewModel.podeConfirmar
                        ? CoresCriacao.roxoPrimario
                        : CoresCriacao.roxoPrimario.opacity(0.4)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .disabled(!viewModel.podeConfirmar)
    }
}

#Preview {
    CriacaoPersonagemView()
}
