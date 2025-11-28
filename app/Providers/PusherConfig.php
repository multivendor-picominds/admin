<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Schema;
use App\Models\PusherCredentail;

class PusherConfig extends ServiceProvider
{
    /**
     * Register services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot()
    {
        $this->app->booted(function () {

            // Prevent errors during "composer install", "php artisan package:discover"
            if (!Schema::hasTable('pusher_credentails')) {
                return; // table not migrated yet → skip
            }

            $pusher = PusherCredentail::first();

            if (!$pusher) {
                return; // no data yet → skip
            }

            $pusherConfig = [
                'driver'  => 'pusher',
                'key'     => $pusher->app_key,
                'secret'  => $pusher->app_secret,
                'app_id'  => $pusher->app_id,
                'options' => [
                    'cluster'   => $pusher->app_cluster,
                    'useTLS'    => true,
                    'encrypted' => true,
                ],
            ];

            // Apply dynamic config
            config(['broadcasting.connections.pusher' => $pusherConfig]);
        });
    }
}
