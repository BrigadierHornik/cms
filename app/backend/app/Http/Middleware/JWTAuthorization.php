<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class JWTAuthorization
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
                try {
            // Check if the token is present in the Authorization header
            $token = $request->bearerToken();  // This retrieves the token from the Authorization header

            JWTAuth::setToken($token)->authenticate();
            $user = Auth::user();

            $date_payload = Carbon::parse(time: JWTAuth::getPayload()->get('password_change_date'))->timestamp;
            $date_user = Carbon::parse(time: $user->password_change_date)->timestamp;

            if($date_user  !== $date_payload) {
                return response()->json(data: ['message' => 'Unauthorized, invalid token. Password was changed'], status: Response::HTTP_UNAUTHORIZED);
            }

            if (!$token) {
                return response()->json(data: ['message' => 'Unauthorized, token not provided'], status: Response::HTTP_UNAUTHORIZED);
            }

            // Attempt to authenticate the user via the token
            if (!JWTAuth::setToken($token)->authenticate()) {
                return response()->json(data: ['message' => 'Unauthorized, invalid token'], status: Response::HTTP_UNAUTHORIZED);
            }
        } catch (JWTException $e) {
            // Return 401 for any JWT errors (invalid, expired, or malformed token)
            return response()->json(data: ['message' => 'Unauthorized, token error', 'error' => $e->getMessage()], status: Response::HTTP_UNAUTHORIZED);
        }
        return $next($request);
    }
}
