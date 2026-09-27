<?php

namespace App\Services;

use App\Models\Usuario;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

/**
 * Serviço responsável pelas regras de negócio de autenticação:
 * cadastro, login e logout de usuários.
 */
class AutenticacaoService
{
    /**
     * Cadastra um novo usuário e já retorna um token de acesso.
     *
     * @param  array{nome: string, email: string, senha: string}  $dados
     * @return array{usuario: Usuario, token: string}
     */
    public function registrar(array $dados): array
    {
        $usuario = Usuario::create([
            'nome' => $dados['nome'],
            'email' => $dados['email'],
            'senha' => Hash::make($dados['senha']),
        ]);

        $token = $usuario->createToken('token-rotina-plus')->plainTextToken;

        return ['usuario' => $usuario, 'token' => $token];
    }

    /**
     * Autentica um usuário pelo e-mail e senha, retornando um novo token.
     *
     * @param  array{email: string, senha: string}  $credenciais
     * @return array{usuario: Usuario, token: string}
     *
     * @throws ValidationException Quando as credenciais são inválidas.
     */
    public function login(array $credenciais): array
    {
        $usuario = Usuario::where('email', $credenciais['email'])->first();

        if (! $usuario || ! Hash::check($credenciais['senha'], $usuario->senha)) {
            throw ValidationException::withMessages([
                'email' => ['As credenciais informadas estão incorretas.'],
            ]);
        }

        $token = $usuario->createToken('token-rotina-plus')->plainTextToken;

        return ['usuario' => $usuario, 'token' => $token];
    }

    /**
     * Revoga o token de acesso atual do usuário (efetua logout).
     */
    public function logout(Usuario $usuario): void
    {
        /** @var \Laravel\Sanctum\PersonalAccessToken $tokenAtual */
        $tokenAtual = $usuario->currentAccessToken();
        $tokenAtual?->delete();
    }
}
