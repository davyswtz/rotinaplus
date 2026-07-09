<?php

namespace App\Exceptions;

use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Throwable;

class ApiExceptionHandler
{
    public static function register(Exceptions $exceptions): void
    {
        $exceptions->render(function (Throwable $e, Request $request) {
            if (! $request->is('api/*')) {
                return null;
            }

            if ($e instanceof ValidationException) {
                return self::error(
                    message: 'Erro de validação.',
                    errors: $e->errors(),
                    status: 422,
                );
            }

            if ($e instanceof AuthenticationException) {
                return self::error(
                    message: 'Não autenticado.',
                    status: 401,
                );
            }

            if ($e instanceof NotFoundHttpException) {
                return self::error(
                    message: 'Recurso não encontrado.',
                    status: 404,
                );
            }

            if ($e instanceof HttpException) {
                return self::error(
                    message: $e->getMessage() ?: 'Erro na requisição.',
                    status: $e->getStatusCode(),
                );
            }

            return self::error(
                message: config('app.debug')
                    ? $e->getMessage()
                    : 'Erro interno do servidor.',
                status: 500,
            );
        });
    }

    public static function error(
        string $message,
        array $errors = [],
        int $status = 400,
    ): JsonResponse {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors' => (object) $errors,
        ], $status);
    }
}
