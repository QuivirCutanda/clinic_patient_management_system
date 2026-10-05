<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class ClinicSeeder extends Seeder {
    public function run(): void {
        $doctorId = DB::table('users')->insertGetId([
            'name' => 'Dr. Smith',
            'email' => 'drsmith@clinic.com',
            'password' => Hash::make('password123'),
            'role' => 'Doctor',
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        DB::table('users')->insert([
            [
                'name' => 'Admin User',
                'email' => 'admin1@clinic.com',
                'password' => Hash::make('password123'),
                'role' => 'Admin',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ]);
    }
}
