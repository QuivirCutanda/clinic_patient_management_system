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


    public function dashboard(Request $request)
{
    $patient = $request->user();
    $patientId = $patient->id;

    $pendingCount = DB::table('appointments')
        ->where('patient_id', $patientId)
        ->where('status', 'Pending')
        ->count();

    $confirmedCount = DB::table('appointments')
        ->where('patient_id', $patientId)
        ->whereIn('status', ['Confirmed', 'Waiting'])
        ->count();

    $historyCount = DB::table('appointments')
        ->where('patient_id', $patientId)
        ->whereIn('status', ['Completed', 'Cancelled'])
        ->count();

    $nextAppointment = DB::table('appointments')
        ->join('users', 'appointments.doctor_id', '=', 'users.id')
        ->where('appointments.patient_id', $patientId)
        ->whereIn('appointments.status', ['Confirmed', 'Waiting'])
        ->where('appointments.appointment_date', '>=', Carbon::today()->toDateString())
        ->select(
            'appointments.id as appointment_id',
            'users.name as doctor_name',
            'appointments.appointment_date',
            'appointments.appointment_time',
            'appointments.status'
        )
        ->orderBy('appointments.appointment_date', 'asc')
        ->orderBy('appointments.appointment_time', 'asc')
        ->first();

    return response()->json([
        'patient_name' => $patient->full_name,
        'counts' => [
            'pending_count' => $pendingCount,
            'confirmed_count' => $confirmedCount,
            'history_count' => $historyCount,
        ],
        'next_appointment' => $nextAppointment,
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

    public function getPatientInfo(Request $request)
    {
    $patient = $request->user();

    return response()->json([
        'id' => $patient->id,
        'email' => $patient->email,
        'full_name' => $patient->full_name,
        'date_of_birth' => $patient->date_of_birth,
        'sex' => $patient->sex,
        'address' => $patient->address,
        'contact_number' => $patient->contact_number,
        'emergency_contact' => $patient->emergency_contact,
        'insurance_provider' => $patient->insurance_provider,
        'blood_type' => $patient->blood_type,
        'allergies' => $patient->allergies,
    ]);
    }

    public function updatePatientInfo(Request $request)
    {
    /** @var \App\Models\Patient $patient */
    $patient = $request->user();

    $request->validate([
        'full_name' => 'required|string|max:150',
        'date_of_birth' => 'required|date',
        'sex' => 'nullable|in:Male,Female,Other',
        'address' => 'required|string',
        'contact_number' => 'required|string|max:20',
        'emergency_contact' => 'required|string|max:150',
        'insurance_provider' => 'required|string|max:150',
        'blood_type' => 'required|string|max:5',
        'allergies' => 'required|string',
    ]);

    $patient->update($request->only([
        'full_name',
        'date_of_birth',
        'sex',
        'address',
        'contact_number',
        'emergency_contact',
        'insurance_provider',
        'blood_type',
        'allergies'
    ]));

    return response()->json([
        'status' => 'success',
        'message' => 'Patient information updated successfully',
        'patient' => $patient
    ]);
    }

    public function getPendingAppointments(Request $request)
{
    $patientId = $request->user()->id;

    $appointments = DB::table('appointments')
        ->join('users', 'appointments.doctor_id', '=', 'users.id')
        ->where('appointments.patient_id', $patientId)
        ->where('appointments.status', 'Pending')
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
        ->orderBy('appointments.appointment_date', 'asc')
        ->orderBy('appointments.appointment_time', 'asc')
        ->get();

    return response()->json($appointments);
}

public function getConfirmedAppointments(Request $request)
{
    $patientId = $request->user()->id;

    $appointments = DB::table('appointments')
        ->join('users', 'appointments.doctor_id', '=', 'users.id')
        ->where('appointments.patient_id', $patientId)
        ->whereIn('appointments.status', ['Confirmed', 'Waiting'])
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
        ->orderBy('appointments.appointment_date', 'asc')
        ->orderBy('appointments.appointment_time', 'asc')
        ->get();

    return response()->json($appointments);
}

public function getHistoryAppointments(Request $request)
{
    $patientId = $request->user()->id;

    $appointments = DB::table('appointments')
        ->join('users', 'appointments.doctor_id', '=', 'users.id')
        ->where('appointments.patient_id', $patientId)
        ->whereIn('appointments.status', ['Completed', 'Cancelled'])
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

public function trackTodayVisit(Request $request)
    {
        $patientId = $request->user()->id ?? $request->query('patient_id');
        $today = Carbon::today()->toDateString();

        $appointment = DB::table('appointments')
            ->join('users as doctors', 'appointments.doctor_id', '=', 'doctors.id')
            ->where('appointments.patient_id', $patientId)
            ->whereDate('appointments.appointment_date', $today)
            ->whereIn('appointments.status', ['Pending', 'Confirmed', 'Waiting', 'Completed'])
            ->select(
                'appointments.id as appointment_id',
                'appointments.doctor_id',
                'doctors.name as doctor_name',
                'appointments.appointment_time',
                'appointments.status as appointment_status',
                'appointments.created_at'
            )
            ->latest('appointments.id')
            ->first();

        if (!$appointment) {
            return response()->json([
                'status' => 'error',
                'message' => 'No active appointment found for today.'
            ], 404);
        }

        $queuePosition = null;
        $totalAhead = null;

        if ($appointment->appointment_status === 'Waiting') {
            $totalAhead = DB::table('appointments')
                ->whereDate('appointment_date', $today)
                ->where('doctor_id', $appointment->doctor_id)
                ->where('status', 'Waiting')
                ->where('id', '<', $appointment->appointment_id)
                ->count();

            $queuePosition = $totalAhead + 1;
        }

        $consultation = DB::table('consultations')
            ->where('appointment_id', $appointment->appointment_id)
            ->select('id as consultation_id', 'vitals', 'diagnosis', 'prescription_list', 'created_at')
            ->first();

        $billing = null;
        if ($consultation) {
            $billing = DB::table('billing')
                ->where('consultation_id', $consultation->consultation_id)
                ->select('id as billing_id', 'fee_amount', 'payment_method', 'status as billing_status')
                ->first();
        }

        $currentStep = 1;
        if ($appointment->appointment_status === 'Waiting') {
            $currentStep = 2;
        } elseif ($consultation && (!$billing || $billing->billing_status === 'Owed')) {
            $currentStep = 3;
        } elseif ($billing && $billing->billing_status === 'Paid') {
            $currentStep = 4;
        }

        return response()->json([
            'status' => 'success',
            'current_step' => $currentStep,
            'tracking' => [
                'appointment_id' => $appointment->appointment_id,
                'doctor_name' => $appointment->doctor_name,
                'appointment_time' => $appointment->appointment_time,
                'status' => $appointment->appointment_status,
                'queue' => [
                    'position' => $queuePosition,
                    'patients_ahead' => $totalAhead,
                ],
                'consultation' => $consultation ? [
                    'consultation_id' => $consultation->consultation_id,
                    'vitals' => $consultation->vitals,
                    'diagnosis' => $consultation->diagnosis,
                    'prescription_list' => $consultation->prescription_list,
                ] : null,
                'billing' => $billing ? [
                    'billing_id' => $billing->billing_id,
                    'fee_amount' => $billing->fee_amount,
                    'payment_method' => $billing->payment_method,
                    'status' => $billing->billing_status,
                ] : null
            ]
        ]);
    }
}
