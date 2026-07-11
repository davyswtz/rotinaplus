// MARK: - Cores do app (espelham TelaBemVindo.swift no iOS)
// Altere aqui para propagar a paleta em todas as telas Android.

export const cores = {
  // Fundo da tela de login (equivalente ao gradiente roxo escuro do iOS)
  fundoSuperior: '#1A0F2E',
  fundoInferior: '#0D081A',
  fundoTela: '#0D081A',

  // Roxo primário dos botões e destaques
  roxoPrimario: '#7A42F5',

  // Textos
  textoPrimario: '#FFFFFF',
  textoSecundario: 'rgba(255, 255, 255, 0.65)',
  textoPlaceholder: 'rgba(255, 255, 255, 0.40)',

  // Campos de formulário
  campoFundo: 'rgba(255, 255, 255, 0.08)',
  campoBorda: 'rgba(255, 255, 255, 0.18)',

  // Mascote / destaque laranja
  laranjaMascote: '#FF8C33',

  // Estados
  erro: '#FF453A',
  botaoDesabilitado: 'rgba(122, 66, 245, 0.45)',

  // Botões sociais
  botaoSocialFundo: 'rgba(255, 255, 255, 0.10)',
  botaoSocialBorda: 'rgba(255, 255, 255, 0.15)',
} as const;
