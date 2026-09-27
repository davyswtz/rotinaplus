import axios from 'axios';

/** Chave usada para guardar o token de acesso no armazenamento local do navegador. */
export const CHAVE_TOKEN = 'rotina_plus_token';

/**
 * Instância do Axios já configurada com a URL base da API e com o
 * cabeçalho de autenticação (token Bearer) injetado automaticamente.
 */
export const clienteApi = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

// Antes de cada requisição, anexa o token salvo (se existir) no cabeçalho Authorization.
clienteApi.interceptors.request.use((configuracao) => {
  const token = localStorage.getItem(CHAVE_TOKEN);

  if (token) {
    configuracao.headers.Authorization = `Bearer ${token}`;
  }

  return configuracao;
});

// Se a API responder 401 (não autenticado), limpa o token local para forçar novo login.
clienteApi.interceptors.response.use(
  (resposta) => resposta,
  (erro) => {
    if (erro.response?.status === 401) {
      localStorage.removeItem(CHAVE_TOKEN);
    }

    return Promise.reject(erro);
  },
);
