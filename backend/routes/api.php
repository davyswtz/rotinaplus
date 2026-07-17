<?php

use App\Http\Controllers\Api\AcademiaController;
use App\Http\Controllers\Api\ClasseController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\FinancasController;
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
        Route::put('/perfil', [PerfilController::class, 'update']);
        Route::get('/dashboard', [DashboardController::class, 'show']);

        Route::get('/missoes', [MissaoController::class, 'index']);
        Route::post('/missoes', [MissaoController::class, 'store']);
        Route::patch('/missoes/{id}/toggle', [MissaoController::class, 'toggle']);

        Route::get('/notificacoes', [NotificacaoController::class, 'index']);
        Route::patch('/notificacoes/{id}/lida', [NotificacaoController::class, 'marcarLida']);
        Route::post('/notificacoes/ler-todas', [NotificacaoController::class, 'lerTodas']);

        Route::get('/academia', [AcademiaController::class, 'show']);
        Route::patch('/academia/dias/{id}/toggle', [AcademiaController::class, 'toggleDia']);

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
