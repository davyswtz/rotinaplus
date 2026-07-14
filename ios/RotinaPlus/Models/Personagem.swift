import Foundation

enum GeneroPersonagem: String, CaseIterable, Identifiable, Codable {
    case masculino
    case feminino

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .masculino: return "Masculino"
        case .feminino: return "Feminino"
        }
    }

    var assetBase: String {
        switch self {
        case .masculino: return "guara_base_m"
        case .feminino: return "guara_base_f"
        }
    }
}

enum CabecaPersonagem: String, CaseIterable, Identifiable, Codable {
    case nenhuma
    case capacete
    case capuz

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .nenhuma: return "Nenhuma"
        case .capacete: return "Capacete"
        case .capuz: return "Capuz"
        }
    }

    var assetCabeca: String? {
        self == .nenhuma ? nil : "guara_cabeca_\(rawValue)"
    }

    var assetThumb: String { "guara_thumb_cabeca_\(rawValue)" }
}

enum CorpoPersonagem: String, CaseIterable, Identifiable, Codable {
    case nenhum
    case peitoralCouro
    case peitoralPlacas
    case robes

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .nenhum: return "Nenhum"
        case .peitoralCouro: return "Peitoral de couro"
        case .peitoralPlacas: return "Peitoral de placas"
        case .robes: return "Robes"
        }
    }

    var assetCorpo: String? {
        self == .nenhum ? nil : "guara_corpo_\(rawValue)"
    }

    var assetThumb: String { "guara_thumb_corpo_\(rawValue)" }
}

enum OmbrosPersonagem: String, CaseIterable, Identifiable, Codable {
    case nenhuma
    case ombreiras

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .nenhuma: return "Nenhuma"
        case .ombreiras: return "Ombreiras"
        }
    }

    var assetOmbros: String? {
        self == .nenhuma ? nil : "guara_ombros_\(rawValue)"
    }

    var assetThumb: String { "guara_thumb_ombros_\(rawValue)" }
}

enum MaosPersonagem: String, CaseIterable, Identifiable, Codable {
    case nenhuma
    case luvas

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .nenhuma: return "Nenhuma"
        case .luvas: return "Luvas"
        }
    }

    var assetMaos: String? {
        self == .nenhuma ? nil : "guara_maos_\(rawValue)"
    }

    var assetThumb: String { "guara_thumb_maos_\(rawValue)" }
}

enum PesPersonagem: String, CaseIterable, Identifiable, Codable {
    case nenhum
    case botasCouro
    case grevas

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .nenhum: return "Nenhum"
        case .botasCouro: return "Botas de couro"
        case .grevas: return "Grevas"
        }
    }

    var assetPes: String? {
        self == .nenhum ? nil : "guara_pes_\(rawValue)"
    }

    var assetThumb: String { "guara_thumb_pes_\(rawValue)" }
}

struct Personagem: Codable, Equatable {
    var nome: String
    var genero: GeneroPersonagem
    var cabeca: CabecaPersonagem
    var corpo: CorpoPersonagem
    var ombros: OmbrosPersonagem
    var maos: MaosPersonagem
    var pes: PesPersonagem

    static let padrao = Personagem(
        nome: "",
        genero: .masculino,
        cabeca: .nenhuma,
        corpo: .nenhum,
        ombros: .nenhuma,
        maos: .nenhuma,
        pes: .nenhum
    )
}
