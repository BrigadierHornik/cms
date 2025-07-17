<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\User;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthenticationController extends Controller
{
    public function login(Request $request)
    {
        try {
            // Validate the request data
            $credentials = $request->validate(rules: [
                'username' => 'required|string',
                'password' => 'required|string',
            ]);

            // Attempt to authenticate the user
            if (!$token = JWTAuth::attempt(credentials: $credentials)) {
                return response()->json(data: ['error' => 'Unauthorized'], status: 401);
            }

            // Return the token on successful authentication
            return response()->json(data: ['token' => $token]);
        } catch (\Exception $e) {
            return response()->json(data: ['error' => 'Login failed', 'message' => $e->getMessage()], status: 500);
        }
    }
    public function register(Request $request)
    {
        // Handle user registration logic here
    }
    public function logout(Request $request)
    {
        // Handle user logout logic here
    }
    public function refresh(Request $request)
    {
        // Handle token refresh logic here
    }
}
