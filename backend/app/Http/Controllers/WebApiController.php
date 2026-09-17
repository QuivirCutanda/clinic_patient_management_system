<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;
use App\Models\User;

class WebApiController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->username)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        $token = $user->createToken('web-token')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'username' => $user->email,
                'role' => $user->role,
            ]
        ]);
    }

    public function dashboard()
    {
        $today = Carbon::today()->toDateString();

        $totalMoney = DB::table('billing')
            ->where('status', 'Paid')
            ->whereDate('payment_date', $today)
            ->sum('fee_amount');

        $patientsWaiting = DB::table('appointments')
            ->whereIn('status', ['Pending', 'Confirmed'])
            ->whereDate('appointment_date', $today)
            ->count();

        $activeDoctors = DB::table('appointments')
            ->whereDate('appointment_date', $today)
            ->distinct('doctor_id')
            ->count('doctor_id');

        return response()->json([
            'total_money_collected_today' => (float)$totalMoney,
            'patients_waiting' => $patientsWaiting,
            'active_doctors' => $activeDoctors,
        ]);
    }

    public function registerPatient(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
            'full_name' => 'required|string',
        ]);

        $id = DB::table('patients')->insertGetId([
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'full_name' => $request->full_name,
            'contact_number' => $request->contact_number,
            'emergency_contact' => $request->emergency_contact,
            'insurance_provider' => $request->insurance_provider,
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        return response()->json(['status' => 'success', 'patient_id' => $id], 201);
    }

public function searchPatients(Request $request)
    {
        $search = trim($request->query('search', ''));

        $query = DB::table('patients');

        if (!empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('full_name', 'LIKE', "%{$search}%")
                  ->orWhere('email', 'LIKE', "%{$search}%");
            });
        }

        $patients = $query->get();

        $result = [];

        foreach ($patients as $patient) {
            $history = DB::table('consultations')
                ->where('patient_id', $patient->id)
                ->select(
                    'id as consultation_id', 
                    'patient_id', 
                    'created_at as consultation_date', 
                    'diagnosis', 
                    'vitals', 
                    'prescription_list'
                )
                ->get();

            $result[] = [
                'id' => $patient->id,
                'full_name' => $patient->full_name,
                'email' => $patient->email,
                'medical_history' => $history,
            ];
        }

        return response()->json($result);
    }

    
    public function getAppointments(Request $request)
    {
        $date = $request->query('date', Carbon::today()->toDateString());

        $appointments = DB::table('appointments')
            ->join('patients', 'appointments.patient_id', '=', 'patients.id')
            ->join('users', 'appointments.doctor_id', '=', 'users.id')
            ->whereDate('appointments.appointment_date', $date)
            ->select('appointments.id', 'patients.full_name as patient_name', 'users.name as doctor_name', 'appointments.appointment_time', 'appointments.status')
            ->get();

        return response()->json($appointments);
    }

    public function addAppointment(Request $request)
    {
        $request->validate([
            'patient_id' => 'required|integer',
            'doctor_id' => 'required|integer',
            'appointment_date' => 'required|date',
            'appointment_time' => 'required',
        ]);

        DB::table('appointments')->insert([
            'patient_id' => $request->patient_id,
            'doctor_id' => $request->doctor_id,
            'appointment_date' => $request->appointment_date,
            'appointment_time' => $request->appointment_time,
            'status' => 'Confirmed',
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        return response()->json(['status' => 'success'], 201);
    }

public function cancelAppointment($id)
    {
        DB::table('appointments')->where('id', $id)->update(['status' => 'Cancelled', 'updated_at' => Carbon::now()]);
        return response()->json(['status' => 'success']);
    }


    public function confirmAppointment($id)
{
    $updated = DB::table('appointments')
        ->where('id', $id)
        ->update([
            'status' => 'Confirmed',
            'updated_at' => Carbon::now(),
        ]);

    if (!$updated) {
        return response()->json([
            'status' => 'error',
            'message' => 'Appointment not found or already confirmed.'
        ], 404);
    }

    return response()->json([
        'status' => 'success',
        'message' => 'Appointment confirmed successfully.'
    ]);
}


public function submitConsultation(Request $request)
{
    $request->validate([
        'appointment_id' => 'required|integer|exists:appointments,id',
        'patient_id' => 'required|integer|exists:patients,id',
        'doctor_id' => 'required|integer|exists:users,id',
        'vitals' => 'required|string',
        'diagnosis' => 'required|string',
        'prescription_list' => 'required|string',
    ]);

    $today = Carbon::today()->toDateString();

    $appointment = DB::table('appointments')
        ->where('id', $request->appointment_id)
        ->where('patient_id', $request->patient_id)
        ->where('doctor_id', $request->doctor_id)
        ->where('appointment_date', $today)
        ->where('status', '!=', 'Cancelled')
        ->first();

    if (!$appointment) {
        return response()->json([
            'status' => 'error',
            'message' => 'Invalid consultation: No active appointment found for this patient and doctor today.'
        ], 422);
    }

    DB::table('consultations')->insert([
        'appointment_id' => $request->appointment_id,
        'patient_id' => $request->patient_id,
        'doctor_id' => $request->doctor_id,
        'vitals' => $request->vitals,
        'diagnosis' => $request->diagnosis,
        'prescription_list' => $request->prescription_list,
        'created_at' => Carbon::now(),
        'updated_at' => Carbon::now(),
    ]);

    return response()->json(['status' => 'success'], 201);
}

public function processBill(Request $request)
{
    $request->validate([
        'consultation_id' => 'required|integer|exists:consultations,id',
        'patient_id' => 'required|integer|exists:patients,id',
        'fee_amount' => 'required|numeric|min:0',
        'payment_method' => 'required|string|in:Cash,Digital',
    ]);

    $consultation = DB::table('consultations')
        ->where('id', $request->consultation_id)
        ->where('patient_id', $request->patient_id)
        ->first();

    if (!$consultation) {
        return response()->json([
            'status' => 'error',
            'message' => 'Invalid transaction: Consultation record does not match the specified Patient ID.'
        ], 422);
    }

    $existingBill = DB::table('billing')
        ->where('consultation_id', $request->consultation_id)
        ->where('status', 'Paid')
        ->first();

    if ($existingBill) {
        return response()->json([
            'status' => 'error',
            'message' => 'Payment has already been processed for this consultation.'
        ], 422);
    }

    $id = DB::table('billing')->insertGetId([
        'consultation_id' => $request->consultation_id,
        'patient_id' => $request->patient_id,
        'fee_amount' => $request->fee_amount,
        'payment_method' => $request->payment_method,
        'status' => 'Paid',
        'payment_date' => Carbon::now(),
        'created_at' => Carbon::now(),
        'updated_at' => Carbon::now(),
    ]);

    return response()->json([
        'status' => 'success',
        'message' => 'Payment logged successfully.',
        'invoice_id' => $id,
    ], 201);
    }
}