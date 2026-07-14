import SwiftUI

struct NotificacaoItem: Identifiable, Equatable {
    let id: UUID
    var icone: String
    var titulo: String
    var mensagem: String
    var quando: String
    var lida: Bool

    init(
        id: UUID = UUID(),
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

    static let exemplos: [NotificacaoItem] = [
        .init(
            icone: "🔥",
            titulo: "Streak em risco!",
            mensagem: "Complete pelo menos 1 hábito hoje para manter sua sequência de 3 dias.",
            quando: "Agora",
            lida: false
        ),
        .init(
            icone: "⚡",
            titulo: "XP desbloqueado",
            mensagem: "Você ganhou 35 XP pela missão diária de hidratação. Continue assim!",
            quando: "2h atrás",
            lida: false
        ),
        .init(
            icone: "🏆",
            titulo: "Conquista próxima",
            mensagem: "Faltam 2 treinos para desbloquear a medalha Guerreiro Consistente.",
            quando: "4h atrás",
            lida: true
        ),
        .init(
            icone: "🦊",
            titulo: "Fox diz: Boa noite!",
            mensagem: "Lembre de registrar seus hábitos antes de dormir. Seu eu de amanhã agradece.",
            quando: "Ontem",
            lida: true
        ),
        .init(
            icone: "💰",
            titulo: "Meta de poupança 69%",
            mensagem: "Você está quase lá! Faltam R$ 620 para bater a meta do mês.",
            quando: "Ontem",
            lida: true
        ),
        .init(
            icone: "📚",
            titulo: "Hora de estudar",
            mensagem: "Que tal uma sessão de Pomodoro agora? 25 min fazem diferença.",
            quando: "2 dias",
            lida: true
        ),
    ]
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

    @State private var itens: [NotificacaoItem] = NotificacaoItem.exemplos

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
        .preferredColorScheme(.dark)
    }

    private var cabecalho: some View {
        HStack {
            Button {
                onVoltar()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(CoresNotificacoes.botaoVoltar))
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Notificações")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                marcarTodasComoLidas()
            } label: {
                Text("Ler todas")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        naoLidas > 0
                            ? CoresNotificacoes.roxoPrimario
                            : CoresNotificacoes.textoTerciario
                    )
            }
            .buttonStyle(.plain)
            .disabled(naoLidas == 0)
            .frame(minWidth: 72, alignment: .trailing)
        }
    }

    private func botaoCard(_ item: NotificacaoItem) -> some View {
        Button {
            marcarComoLida(item.id)
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

    private func marcarComoLida(_ id: UUID) {
        guard let indice = itens.firstIndex(where: { $0.id == id }), !itens[indice].lida else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            itens[indice].lida = true
        }
    }

    private func marcarTodasComoLidas() {
        withAnimation(.easeInOut(duration: 0.2)) {
            for indice in itens.indices {
                itens[indice].lida = true
            }
        }
    }
}

#Preview {
    TelaNotificacoes()
}
