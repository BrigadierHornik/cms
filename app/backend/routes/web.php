<?php

use Illuminate\Support\Facades\Route;
use Illuminate\View\View;

Route::get(uri: '/api/', action: function (): View {
    return view(view: 'welcome');
});
