<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AutenticacaoService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Controller responsável pelos endpoints de autenticação da API.
 */
class AutenticacaoController extends Controller
{
    public function __construct(
        private readonly AutenticacaoService $autenticacaoService,
    ) {}

    /**
     * Cadastra um novo usuário no sistema.
     */
    public function registrar(Request $request): JsonResponse
    {
        $dados = $request->validate([
            'nome' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:usuarios,email'],
            'senha' => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        $resultado = $this->autenticacaoService->registrar($dados);

        return response()->json([
            'usuario' => $resultado['usuario'],
            'token' => $resultado['token'],
        ], 201);
    }

    /**
     * Autentica um usuário existente e devolve um token de acesso.
     */
    public function login(Request $request): JsonResponse
    {
        $credenciais = $request->validate([
            'email' => ['required', 'string', 'email'],
            'senha' => ['required', 'string'],
        ]);

        $resultado = $this->autenticacaoService->login($credenciais);

        return response()->json([
            'usuario' => $resultado['usuario'],
            'token' => $resultado['token'],
        ]);
    }

    /**
     * Efetua o logout do usuário autenticado (revoga o token atual).
     */
    public function logout(Request $request): JsonResponse
    {
        $this->autenticacaoService->logout($request->user());

        return response()->json(['mensagem' => 'Logout realizado com sucesso.']);
    }

    /**
     * Retorna os dados do usuário autenticado.
     */
    public function usuarioAutenticado(Request $request): JsonResponse
    {
        return response()->json($request->user());
    }
}
