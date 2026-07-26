// MARK: - Paleta Guará / Cerrado
// Identidade visual: pelagem do Guará + terra quente do cerrado (sem roxo genérico).
// Espelhada nos enums de cores do iOS.

export const cores = {
  // Fundo — noite quente de cerrado (não roxo)
  fundoSuperior: '#18140F',
  fundoInferior: '#0A0806',
  fundoTela: '#0A0806',

  // Primário — laranja Guará (CTAs, tabs, fills)
  roxoPrimario: '#E87830',
  corPrimaria: '#E87830',

  // Textos
  textoPrimario: '#FFFFFF',
  textoSecundario: 'rgba(255, 255, 255, 0.65)',
  textoPlaceholder: 'rgba(255, 255, 255, 0.40)',

  // Campos de formulário
  campoFundo: 'rgba(255, 255, 255, 0.08)',
  campoBorda: 'rgba(255, 255, 255, 0.18)',

  // Destaque do mascote (mais claro que o primário)
  laranjaMascote: '#FF9B4A',

  // XP / destaques secundários
  acentoXp: '#F0A859',
  acentoOasis: '#3DB89A',

  // Superfícies
  footerFundo: '#161310',
  cardFundo: '#241C14',

  // Estados
  erro: '#FF453A',
  botaoDesabilitado: 'rgba(232, 120, 48, 0.45)',

  // Botões sociais
  botaoSocialFundo: 'rgba(255, 255, 255, 0.10)',
  botaoSocialBorda: 'rgba(255, 255, 255, 0.15)',
} as const;
