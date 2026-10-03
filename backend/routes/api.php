<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\WebApiController;
use App\Http\Controllers\MobileApiController;

// Public Routes
Route::post('/web/login', [WebApiController::class, 'login']);
Route::post('/mobile/register', [MobileApiController::class, 'register']);
Route::post('/mobile/login', [MobileApiController::class, 'login']);

// Protected Web Routes (Admin/Doctor/Nurse/Cashier)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    
    Route::get('/web/dashboard', [WebApiController::class, 'dashboard']);
    Route::get('/web/todays-queue', [WebApiController::class, 'getTodaysQueue']);
    Route::patch('/web/appointments/{id}/status', [WebApiController::class, 'updateQueueStatus']); 
    Route::post('/web/patients', [WebApiController::class, 'registerPatient']);
    Route::get('/web/patients', [WebApiController::class, 'searchPatients']);
    Route::get('/web/appointments', [WebApiController::class, 'getAppointments']);
    Route::post('/web/appointments', [WebApiController::class, 'addAppointment']);
    Route::patch('/web/appointments/{id}/cancel', [WebApiController::class, 'cancelAppointment']);
    Route::patch('/web/appointments/{id}/confirm', [WebApiController::class, 'confirmAppointment']);
    Route::post('/web/consultations', [WebApiController::class, 'submitConsultation']);
    Route::post('/web/billing', [WebApiController::class, 'processBill']);
});

// Protected Mobile Routes (Patients)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/mobile/doctors', [MobileApiController::class, 'getDoctors']);
    Route::post('/mobile/appointments', [MobileApiController::class, 'bookAppointment']);
    Route::get('/mobile/appointments', [MobileApiController::class, 'getAppointments']);
    Route::get('/mobile/my-records', [MobileApiController::class, 'getRecords']);
    Route::get('/mobile/my-bills', [MobileApiController::class, 'getBills']);
    Route::get('/mobile/patient-info', [MobileApiController::class, 'getPatientInfo']);
    Route::put('/mobile/patient-info', [MobileApiController::class, 'updatePatientInfo']); 

});