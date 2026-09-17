<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;
use App\Models\Patient;

class MobileApiController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
            'full_name' => 'required|string',
        ]);

        Patient::create([
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'full_name' => $request->full_name,
            'contact_number' => $request->contact_number,
            'emergency_contact' => $request->emergency_contact,
            'insurance_provider' => $request->insurance_provider,
        ]);

        return response()->json(['status' => 'success'], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $patient = Patient::where('email', $request->email)->first();

        if (!$patient || !Hash::check($request->password, $patient->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        $token = $patient->createToken('mobile-token')->plainTextToken;

        return response()->json([
            'token' => $token,
            'patient' => [
                'id' => $patient->id,
                'full_name' => $patient->full_name,
                'email' => $patient->email,
            ]
        ]);
    }

    public function getDoctors()
    {
        $doctors = DB::table('users')
            ->where('role', 'Doctor')
            ->select('id', 'name')
            ->get();

        return response()->json($doctors);
    }


    public function getAppointments(Request $request)
    {
        $patientId = $request->user()->id;

        $appointments = DB::table('appointments')
            ->join('users', 'appointments.doctor_id', '=', 'users.id')
            ->where('appointments.patient_id', $patientId)
            ->select(
                'appointments.id as appointment_id',
                'appointments.patient_id',
                'appointments.doctor_id',
                'users.name as doctor_name',
                'appointments.appointment_date',
                'appointments.appointment_time',
                'appointments.status',
                'appointments.created_at',
                'appointments.updated_at'
            )
            ->orderBy('appointments.appointment_date', 'desc')
            ->orderBy('appointments.appointment_time', 'desc')
            ->get();

        return response()->json($appointments);
    }


    public function bookAppointment(Request $request)
    {
        $request->validate([
            'doctor_id' => 'required|integer',
            'appointment_date' => 'required|date',
            'appointment_time' => 'required',
        ]);

        $patientId = $request->user()->id;

        DB::table('appointments')->insert([
            'patient_id' => $patientId,
            'doctor_id' => $request->doctor_id,
            'appointment_date' => $request->appointment_date,
            'appointment_time' => $request->appointment_time,
            'status' => 'Pending',
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        return response()->json(['status' => 'success'], 201);
    }

public function getRecords(Request $request)
{
    $patientId = $request->user()->id;

    $records = DB::table('consultations')
        ->join('users', 'consultations.doctor_id', '=', 'users.id')
        ->where('consultations.patient_id', $patientId)
        ->select(
            'consultations.created_at as consultation_date', 
            'users.name as doctor_name', 
            'consultations.diagnosis', 
            'consultations.vitals', 
            'consultations.prescription_list'
        )
        ->orderBy('consultations.created_at', 'desc')
        ->get();

    return response()->json($records);
}

    public function getBills(Request $request)
    {
        $patientId = $request->user()->id;

        $bills = DB::table('billing')
            ->where('patient_id', $patientId)
            ->select('id', 'fee_amount', 'payment_method', 'status')
            ->orderBy('id', 'desc')
            ->get();

        return response()->json($bills);
    }
}
