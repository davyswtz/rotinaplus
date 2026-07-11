<?php

use App\Http\Controllers\Api\RotinaController;
use App\Http\Controllers\Auth\SocialAuthController;
use App\Http\Controllers\Auth\LoginController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::apiResource('rotinas', RotinaController::class);
    Route::post('/auth/social', [SocialAuthController::class, 'login']);
    Route::post('/auth/login', [LoginController::class, 'login']);
});