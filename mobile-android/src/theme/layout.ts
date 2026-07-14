import { Dimensions, PixelRatio, ScaledSize } from 'react-native';

function base(): ScaledSize {
  return Dimensions.get('window');
}

/** Métricas responsivas do dashboard (espelha LayoutDashboard.swift). */
export function getLayoutDashboard(width?: number) {
  const largura = width ?? base().width;
  const compacto = largura < 360;
  const estreito = largura < 340;

  const paddingHorizontal =
    largura < 340 ? 12 : largura < 390 ? 14 : largura < 430 ? 16 : 20;

  const gapSecao = compacto ? 10 : 12;
  const gapGrade = compacto ? 8 : 10;

  /** Largura de card em grade 3 colunas (atalhos). */
  const cardAtalho =
    (largura - paddingHorizontal * 2 - gapGrade * 2) / 3;

  return {
    largura,
    compacto,
    estreito,
    paddingHorizontal,
    gapSecao,
    gapGrade,
    cardAtalho,
    fonte: (size: number) =>
      Math.round(PixelRatio.roundToNearestPixel(size * (compacto ? 0.92 : 1))),
  };
}
