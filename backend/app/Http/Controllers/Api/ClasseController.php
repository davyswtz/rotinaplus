<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Support\ClassesCatalog;
use Illuminate\Http\JsonResponse;

class ClasseController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => ClassesCatalog::all(),
        ]);
    }
}
