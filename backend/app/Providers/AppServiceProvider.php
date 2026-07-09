<?php

namespace App\Providers;

use App\Repositories\RotinaRepository;
use App\Repositories\RotinaRepositoryInterface;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(RotinaRepositoryInterface::class, RotinaRepository::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
