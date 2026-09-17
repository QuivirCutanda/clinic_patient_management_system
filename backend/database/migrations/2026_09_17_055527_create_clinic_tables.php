<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        // Users Table
        // Schema::create('users', function (Blueprint $table) {
        //     $table->id();
        //     $table->string('username')->unique();
        //     $table->string('password');
        //     $table->enum('role', ['Admin', 'Doctor', 'Nurse', 'Cashier']);
        //     $table->timestamps();
        // });

        // Patients Table
        Schema::create('patients', function (Blueprint $table) {
            $table->id();
            $table->string('email')->unique();
            $table->string('password');
            $table->string('full_name');
            $table->string('contact_number')->nullable();
            $table->string('emergency_contact')->nullable();
            $table->string('insurance_provider')->nullable();
            $table->timestamps();
        });

        // Appointments Table
        Schema::create('appointments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patient_id')->constrained('patients')->onDelete('cascade');
            $table->foreignId('doctor_id')->constrained('users')->onDelete('cascade');
            $table->date('appointment_date');
            $table->time('appointment_time');
            $table->enum('status', ['Pending', 'Confirmed', 'Cancelled'])->default('Pending');
            $table->timestamps();
        });

        // Consultations Table
        Schema::create('consultations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('appointment_id')->constrained('appointments')->onDelete('cascade');
            $table->foreignId('patient_id')->constrained('patients')->onDelete('cascade');
            $table->foreignId('doctor_id')->constrained('users')->onDelete('cascade');
            $table->text('vitals');
            $table->text('diagnosis');
            $table->text('prescription_list');
            $table->timestamps();
        });

        // Billing Table
        Schema::create('billing', function (Blueprint $table) {
            $table->id();
            $table->foreignId('consultation_id')->constrained('consultations')->onDelete('cascade');
            $table->foreignId('patient_id')->constrained('patients')->onDelete('cascade');
            $table->decimal('fee_amount', 10, 2);
            $table->enum('payment_method', ['Cash', 'Digital']);
            $table->enum('status', ['Owed', 'Paid'])->default('Owed');
            $table->timestamp('payment_date')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void {
        Schema::dropIfExists('billing');
        Schema::dropIfExists('consultations');
        Schema::dropIfExists('appointments');
        Schema::dropIfExists('patients');
        Schema::dropIfExists('users');
    }
};
