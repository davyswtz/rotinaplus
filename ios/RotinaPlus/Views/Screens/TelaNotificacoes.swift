import SwiftUI

struct NotificacaoItem: Identifiable, Equatable {
    let id: Int
    var icone: String
    var titulo: String
    var mensagem: String
    var quando: String
    var lida: Bool

    init(
        id: Int,
        icone: String,
        titulo: String,
        mensagem: String,
        quando: String,
        lida: Bool
    ) {
        self.id = id
        self.icone = icone
        self.titulo = titulo
        self.mensagem = mensagem
        self.quando = quando
        self.lida = lida
    }
}

private enum CoresNotificacoes {
    static let fundoSuperior = Color(red: 0.10, green: 0.06, blue: 0.18)
    static let fundoInferior = Color(red: 0.05, green: 0.03, blue: 0.10)
    static let roxoPrimario = Color(red: 0.48, green: 0.26, blue: 0.96)
    static let cardNaoLida = Color(red: 0.14, green: 0.09, blue: 0.24)
    static let cardLida = Color.white.opacity(0.04)
    static let textoSecundario = Color.white.opacity(0.55)
    static let textoTerciario = Color.white.opacity(0.35)
    static let botaoVoltar = Color.white.opacity(0.08)
}

struct TelaNotificacoes: View {
    var onVoltar: () -> Void = {}

    @State private var itens: [NotificacaoItem] = []
    @State private var carregando = true
    @State private var erro: String?

    private var naoLidas: Int {
        itens.filter { !$0.lida }.count
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CoresNotificacoes.fundoSuperior, CoresNotificacoes.fundoInferior],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                cabecalho
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)

                if carregando {
                    Spacer()
                    ProgressView().tint(.white)
                    Spacer()
                } else if let erro {
                    Spacer()
                    Text(erro)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Tentar de novo") {
                        Task { await carregar() }
                    }
                    .foregroundStyle(CoresNotificacoes.roxoPrimario)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(itens) { item in
                                botaoCard(item)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .task { await carregar() }
    }

    private var cabecalho: some View {
        HStack {
            Button(action: onVoltar) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(CoresNotificacoes.botaoVoltar))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Notificações")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Text(naoLidas == 0 ? "Tudo lido" : "\(naoLidas) não lidas")
                    .font(.system(size: 13))
                    .foregroundStyle(CoresNotificacoes.textoSecundario)
            }

            Spacer()

            if naoLidas > 0 {
                Button("Ler todas") {
                    Task { await lerTodas() }
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(CoresNotificacoes.roxoPrimario)
            }
        }
    }

    private func botaoCard(_ item: NotificacaoItem) -> some View {
        Button {
            Task { await marcarComoLida(item.id) }
        } label: {
            card(item)
        }
        .buttonStyle(.plain)
    }

    private func card(_ item: NotificacaoItem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(item.icone)
                .font(.system(size: 28))
                .frame(width: 36, alignment: .center)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.titulo)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)

                Text(item.mensagem)
                    .font(.system(size: 14))
                    .foregroundStyle(CoresNotificacoes.textoSecundario)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.quando)
                    .font(.system(size: 12))
                    .foregroundStyle(CoresNotificacoes.textoTerciario)
                    .padding(.top, 2)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(item.lida ? CoresNotificacoes.cardLida : CoresNotificacoes.cardNaoLida)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    item.lida ? Color.clear : CoresNotificacoes.roxoPrimario.opacity(0.55),
                    lineWidth: 1.5
                )
        )
        .overlay(alignment: .topTrailing) {
            if !item.lida {
                Circle()
                    .fill(CoresNotificacoes.roxoPrimario)
                    .frame(width: 8, height: 8)
                    .padding(12)
            }
        }
    }

    @MainActor
    private func carregar() async {
        carregando = true
        erro = nil
        do {
            let lista = try await RotinaPlusAPI.notificacoes()
            itens = lista.map { $0.asItem() }
        } catch {
            erro = error.localizedDescription
        }
        carregando = false
    }

    @MainActor
    private func marcarComoLida(_ id: Int) async {
        guard let indice = itens.firstIndex(where: { $0.id == id }), !itens[indice].lida else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            itens[indice].lida = true
        }
        do {
            try await RotinaPlusAPI.marcarNotificacaoLida(id: id)
        } catch {
            itens[indice].lida = false
        }
    }

    @MainActor
    private func lerTodas() async {
        withAnimation(.easeInOut(duration: 0.2)) {
            for indice in itens.indices {
                itens[indice].lida = true
            }
        }
        try? await RotinaPlusAPI.lerTodasNotificacoes()
    }
}

#Preview {
    TelaNotificacoes()
}
