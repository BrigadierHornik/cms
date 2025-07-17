<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\JsonResponse;



Route::get(uri: '/', action: function (): JsonResponse {
    return response()->json(data: ['message' => 'Welcome to the API']);
});

Route::get(uri: '/test', action: function (): JsonResponse {
    return response()->json(data: ['message' => 'Test endpoint']);
});

Route::post(uri: '/login', action: [\App\Http\Controllers\AuthenticationController::class, 'login']);

Route::get(uri: '/AuthTest', action: function (): JsonResponse {
    return response()->json(data: ['message' => 'Auth Test endpoint']);
})->middleware(middleware: \App\Http\Middleware\JWTAuthorization::class);