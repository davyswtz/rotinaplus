import Foundation

struct Rotina: Codable, Identifiable {
    let id: Int
    let titulo: String
    let descricao: String?
    let concluida: Bool
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case titulo
        case descricao
        case concluida
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
