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
                'name' => 'Nurse Jen',
                'email' => 'nursejen@clinic.com',
                'password' => Hash::make('password123'),
                'role' => 'Nurse',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'name' => 'Cashier Amy',
                'email' => 'cashieramy@clinic.com',
                'password' => Hash::make('password123'),
                'role' => 'Cashier',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'name' => 'Admin User',
                'email' => 'admin1@clinic.com',
                'password' => Hash::make('password123'),
                'role' => 'Admin',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ]);

        $patientId = DB::table('patients')->insertGetId([
            'email' => 'juan@example.com',
            'password' => Hash::make('password123'),
            'full_name' => 'Juan Dela Cruz',
            'contact_number' => '09171234567',
            'emergency_contact' => 'Maria Dela Cruz - 09177654321',
            'insurance_provider' => 'PhilHealth',
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        $appointmentId = DB::table('appointments')->insertGetId([
            'patient_id' => $patientId,
            'doctor_id' => $doctorId,
            'appointment_date' => Carbon::today()->toDateString(),
            'appointment_time' => '10:00:00',
            'status' => 'Confirmed',
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        $consultationId = DB::table('consultations')->insertGetId([
            'appointment_id' => $appointmentId,
            'patient_id' => $patientId,
            'doctor_id' => $doctorId,
            'vitals' => 'BP: 120/80, Temp: 36.8°C',
            'diagnosis' => 'Common Cold',
            'prescription_list' => 'Paracetamol 500mg every 4 hours as needed.',
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        DB::table('billing')->insert([
            'consultation_id' => $consultationId,
            'patient_id' => $patientId,
            'fee_amount' => 500.00,
            'payment_method' => 'Cash',
            'status' => 'Paid',
            'payment_date' => Carbon::now(),
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);
    }
}
