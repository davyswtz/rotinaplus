import Foundation
import Combine

@MainActor
final class CriacaoPersonagemViewModel: ObservableObject {
    @Published var nome: String = ""
    @Published var genero: GeneroPersonagem = Personagem.padrao.genero
    @Published var cabeca: CabecaPersonagem = Personagem.padrao.cabeca
    @Published var corpo: CorpoPersonagem = Personagem.padrao.corpo
    @Published var ombros: OmbrosPersonagem = Personagem.padrao.ombros
    @Published var maos: MaosPersonagem = Personagem.padrao.maos
    @Published var pes: PesPersonagem = Personagem.padrao.pes
    @Published var categoriaAtiva: CategoriaCustomizacao = .corpo

    enum CategoriaCustomizacao: String, CaseIterable, Identifiable {
        case corpo
        case cabeca
        case ombros
        case maos
        case pes

        var id: String { rawValue }

        var titulo: String {
            switch self {
            case .corpo: return "Corpo"
            case .cabeca: return "Cabeça"
            case .ombros: return "Ombros"
            case .maos: return "Mãos"
            case .pes: return "Pés"
            }
        }
    }

    var personagem: Personagem {
        Personagem(
            nome: nome.trimmingCharacters(in: .whitespacesAndNewlines),
            genero: genero,
            cabeca: cabeca,
            corpo: corpo,
            ombros: ombros,
            maos: maos,
            pes: pes
        )
    }

    var podeConfirmar: Bool {
        !personagem.nome.isEmpty
    }

    func salvar() -> Personagem? {
        guard podeConfirmar else { return nil }
        let criado = personagem
        PersonagemStore.salvar(criado)
        return criado
    }
}

enum PersonagemStore {
    private static let chave = "rotinaplus.personagem"

    static func salvar(_ personagem: Personagem) {
        guard let data = try? JSONEncoder().encode(personagem) else { return }
        UserDefaults.standard.set(data, forKey: chave)
        UserDefaults.standard.set(true, forKey: "rotinaplus.hasCharacter")
    }

    static func carregar() -> Personagem? {
        guard let data = UserDefaults.standard.data(forKey: chave) else { return nil }
        return try? JSONDecoder().decode(Personagem.self, from: data)
    }

    static var temPersonagem: Bool {
        UserDefaults.standard.bool(forKey: "rotinaplus.hasCharacter")
    }
}
