import SwiftUI

/// Camadas: base → pés → corpo → ombros → mãos → cabeça (rosto) → acessório de cabeça
struct PersonagemSpriteView: View {
    let genero: GeneroPersonagem
    let corpo: CorpoPersonagem
    let ombros: OmbrosPersonagem
    let maos: MaosPersonagem
    let cabeca: CabecaPersonagem
    let pes: PesPersonagem

    var body: some View {
        ZStack {
            pixelLayer("guara_base_m")

            if let asset = pes.assetPes {
                pixelLayer(asset)
            }
            if let asset = corpo.assetCorpo {
                pixelLayer(asset)
            }
            if let asset = ombros.assetOmbros {
                pixelLayer(asset)
            }
            if let asset = maos.assetMaos {
                pixelLayer(asset)
            }
            // Rosto sempre por cima da roupa (paper-doll)
            pixelLayer("guara_head")
            if let asset = cabeca.assetCabeca {
                pixelLayer(asset)
            }
        }
        // Feminino espelha o personagem inteiro (base + equipamento juntos)
        .scaleEffect(x: genero == .feminino ? -1 : 1, y: 1)
        .animation(.easeInOut(duration: 0.2), value: genero)
        .animation(.easeInOut(duration: 0.2), value: corpo)
        .animation(.easeInOut(duration: 0.2), value: ombros)
        .animation(.easeInOut(duration: 0.2), value: maos)
        .animation(.easeInOut(duration: 0.2), value: cabeca)
        .animation(.easeInOut(duration: 0.2), value: pes)
        .drawingGroup()
    }

    private func pixelLayer(_ name: String) -> some View {
        Image(name)
            .resizable()
            .interpolation(.none)
            .scaledToFit()
    }
}

#Preview {
    ZStack {
        Color.black
        PersonagemSpriteView(
            genero: .masculino,
            corpo: .peitoralPlacas,
            ombros: .ombreiras,
            maos: .nenhuma,
            cabeca: .capacete,
            pes: .grevas
        )
        .frame(width: 240, height: 320)
    }
}
