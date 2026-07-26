<?php

use App\Http\Controllers\Api\AcademiaController;
use App\Http\Controllers\Api\AmigoController;
use App\Http\Controllers\Api\ClasseController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\FinancasController;
use App\Http\Controllers\Api\HabitoController;
use App\Http\Controllers\Api\MissaoController;
use App\Http\Controllers\Api\NotificacaoController;
use App\Http\Controllers\Api\PerfilController;
use App\Http\Controllers\Api\PluggyController;
use App\Http\Controllers\Api\RotinaController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\SocialAuthController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::post('/auth/social', [SocialAuthController::class, 'login']);
    Route::post('/auth/login', [LoginController::class, 'login']);
    Route::post('/auth/register', [RegisterController::class, 'register']);
    Route::get('/classes', [ClasseController::class, 'index']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [PerfilController::class, 'show']);
        Route::get('/perfil/stats', [PerfilController::class, 'stats']);
        Route::put('/perfil', [PerfilController::class, 'update']);
        Route::get('/dashboard', [DashboardController::class, 'show']);

        Route::get('/amigos', [AmigoController::class, 'index']);
        Route::post('/amigos', [AmigoController::class, 'store']);
        Route::post('/amigos/{id}/aceitar', [AmigoController::class, 'aceitar']);
        Route::post('/amigos/{id}/recusar', [AmigoController::class, 'recusar']);
        Route::delete('/amigos/{id}', [AmigoController::class, 'destroy']);

        Route::get('/missoes', [MissaoController::class, 'index']);
        Route::post('/missoes', [MissaoController::class, 'store']);
        Route::patch('/missoes/{id}/toggle', [MissaoController::class, 'toggle']);

        Route::get('/habitos', [HabitoController::class, 'index']);
        Route::post('/habitos', [HabitoController::class, 'store']);
        Route::patch('/habitos/{id}', [HabitoController::class, 'update']);
        Route::delete('/habitos/{id}', [HabitoController::class, 'destroy']);
        Route::patch('/habitos/{id}/checkin', [HabitoController::class, 'toggleCheckin']);
        Route::patch('/habitos/{id}/nota', [HabitoController::class, 'atualizarNota']);

        Route::get('/notificacoes', [NotificacaoController::class, 'index']);
        Route::patch('/notificacoes/{id}/lida', [NotificacaoController::class, 'marcarLida']);
        Route::post('/notificacoes/ler-todas', [NotificacaoController::class, 'lerTodas']);

        Route::get('/academia', [AcademiaController::class, 'show']);
        Route::patch('/academia/dias/{id}/toggle', [AcademiaController::class, 'toggleDia']);
        Route::get('/academia/exercicios', [AcademiaController::class, 'catalogoExercicios']);
        Route::get('/academia/treinos/historico', [AcademiaController::class, 'historico']);
        Route::post('/academia/treinos', [AcademiaController::class, 'storeTreino']);
        Route::get('/academia/treinos/{id}', [AcademiaController::class, 'showTreino']);
        Route::put('/academia/treinos/{id}', [AcademiaController::class, 'updateTreino']);
        Route::delete('/academia/treinos/{id}', [AcademiaController::class, 'destroyTreino']);
        Route::patch('/academia/treinos/{id}/exercicios/{exercicioId}/toggle', [AcademiaController::class, 'toggleExercicio']);
        Route::post('/academia/treinos/{id}/concluir', [AcademiaController::class, 'concluirTreino']);
        Route::post('/academia/esportes/sessoes', [AcademiaController::class, 'storeEsporte']);
        Route::delete('/academia/esportes/sessoes/{id}', [AcademiaController::class, 'destroyEsporte']);

        Route::get('/financas', [FinancasController::class, 'show']);
        Route::post('/financas/transacoes', [FinancasController::class, 'storeTransacao']);
        Route::delete('/financas/transacoes/{id}', [FinancasController::class, 'destroyTransacao']);
        Route::post('/financas/metas', [FinancasController::class, 'storeMeta']);
        Route::patch('/financas/metas/{id}', [FinancasController::class, 'updateMeta']);

        Route::get('/financas/pluggy/status', [PluggyController::class, 'status']);
        Route::post('/financas/pluggy/connect-token', [PluggyController::class, 'connectToken']);
        Route::post('/financas/pluggy/vincular', [PluggyController::class, 'vincular']);
        Route::post('/financas/pluggy/sincronizar', [PluggyController::class, 'sincronizar']);

        Route::apiResource('rotinas', RotinaController::class);
    });
});
