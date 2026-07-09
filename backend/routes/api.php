<?php

use App\Http\Controllers\Api\RotinaController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::apiResource('rotinas', RotinaController::class);
});
