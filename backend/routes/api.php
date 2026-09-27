<?php

use App\Http\Controllers\Api\AguaController;
use App\Http\Controllers\Api\AutenticacaoController;
use App\Http\Controllers\Api\CategoriaController;
use App\Http\Controllers\Api\HabitoController;
use App\Http\Controllers\Api\HumorController;
use App\Http\Controllers\Api\MetaController;
use App\Http\Controllers\Api\ReflexaoController;
use App\Http\Controllers\Api\TarefaController;
use App\Http\Controllers\Api\TransacaoController;
use Illuminate\Support\Facades\Route;

// ---- Rotas públicas de autenticação ----
Route::post('/registro', [AutenticacaoController::class, 'registrar']);
Route::post('/login', [AutenticacaoController::class, 'login']);

// ---- Rotas protegidas (exigem token via Sanctum) ----
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AutenticacaoController::class, 'logout']);
    Route::get('/usuario', [AutenticacaoController::class, 'usuarioAutenticado']);

    // Categorias
    Route::get('/categorias', [CategoriaController::class, 'index']);
    Route::post('/categorias', [CategoriaController::class, 'store']);
    Route::put('/categorias/{categoria}', [CategoriaController::class, 'update']);
    Route::delete('/categorias/{categoria}', [CategoriaController::class, 'destroy']);

    // Tarefas (itens de rotina)
    Route::get('/tarefas', [TarefaController::class, 'index']);
    Route::post('/tarefas', [TarefaController::class, 'store']);
    Route::put('/tarefas/{tarefa}', [TarefaController::class, 'update']);
    Route::patch('/tarefas/{tarefa}/concluir', [TarefaController::class, 'alternarConclusao']);
    Route::delete('/tarefas/{tarefa}', [TarefaController::class, 'destroy']);

    // Hábitos e quadro de acompanhamento
    Route::get('/habitos', [HabitoController::class, 'index']);
    Route::post('/habitos', [HabitoController::class, 'store']);
    Route::put('/habitos/{habito}', [HabitoController::class, 'update']);
    Route::delete('/habitos/{habito}', [HabitoController::class, 'destroy']);
    Route::patch('/habitos/{habito}/registrar-dia', [HabitoController::class, 'alternarRegistroDoDia']);

    // Metas
    Route::get('/metas', [MetaController::class, 'index']);
    Route::post('/metas', [MetaController::class, 'store']);
    Route::put('/metas/{meta}', [MetaController::class, 'update']);
    Route::patch('/metas/{meta}/concluir', [MetaController::class, 'alternarConclusao']);
    Route::delete('/metas/{meta}', [MetaController::class, 'destroy']);

    // Humor diário
    Route::get('/humor', [HumorController::class, 'index']);
    Route::post('/humor', [HumorController::class, 'definir']);

    // Consumo de água
    Route::get('/agua', [AguaController::class, 'index']);
    Route::post('/agua/adicionar', [AguaController::class, 'adicionar']);
    Route::post('/agua/remover', [AguaController::class, 'remover']);

    // Reflexão semanal
    Route::get('/reflexao', [ReflexaoController::class, 'mostrar']);
    Route::post('/reflexao', [ReflexaoController::class, 'salvar']);

    // Financeiro (receitas e despesas)
    Route::get('/transacoes', [TransacaoController::class, 'index']);
    Route::post('/transacoes', [TransacaoController::class, 'store']);
    Route::put('/transacoes/{transacao}', [TransacaoController::class, 'update']);
    Route::delete('/transacoes/{transacao}', [TransacaoController::class, 'destroy']);
});
