<?php

use App\Http\Middleware\JWTAuthorization;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
        apiPrefix: '/',
    )
    ->withMiddleware(callback: function (Middleware $middleware): void {
        $middleware->statefulApi();
        $middleware->alias(aliases: ['jwtAuth' => JWTAuthorization::class]);
    })
    ->withExceptions(using: function (Exceptions $exceptions): void {
        //
    })->create();
