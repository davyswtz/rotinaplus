/** Catálogo de classes — espelha GET /api/v1/classes (ClassesCatalog.php). */

export type ClasseHeroi = {
  key: string;
  nome: string;
  emoji: string;
  descricao: string;
  bonus: string[];
  cor: string;
};

export const CLASSES_HEROI: ClasseHeroi[] = [
  {
    key: 'guerreiro',
    nome: 'Guerreiro',
    emoji: '⚔️',
    descricao: 'Foco em treinos e disciplina física',
    bonus: ['+20% XP na academia', 'Streak bônus x2', 'Resistência lendária'],
    cor: '#FF7A47',
  },
  {
    key: 'estudioso',
    nome: 'Estudioso',
    emoji: '📚',
    descricao: 'Domina conhecimento e aprendizado',
    bonus: ['+20% XP nos estudos', 'Memória aprimorada', 'Foco sobrenatural'],
    cor: '#59D9EB',
  },
  {
    key: 'investidor',
    nome: 'Investidor',
    emoji: '💰',
    descricao: 'Mestre das finanças e crescimento',
    bonus: ['+20% XP em finanças', 'Renda passiva bônus', 'Visão de mercado'],
    cor: '#59DB85',
  },
  {
    key: 'sabio',
    nome: 'Sábio',
    emoji: '🔮',
    descricao: 'Equilibra todas as áreas da vida',
    bonus: ['+10% XP em tudo', 'Bônus de equilíbrio', 'Sabedoria ancestral'],
    cor: '#B88CF9',
  },
];

export function findClasseByKey(key: string): ClasseHeroi {
  return CLASSES_HEROI.find((c) => c.key === key) ?? CLASSES_HEROI[3];
}
