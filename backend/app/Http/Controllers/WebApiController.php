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

public function dashboard(Request $request)
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

    $paymentBreakdown = DB::table('billing')
        ->where('status', 'Paid')
        ->whereDate('payment_date', $today)
        ->select('payment_method', DB::raw('SUM(fee_amount) as total'))
        ->groupBy('payment_method')
        ->pluck('total', 'payment_method');

    $todayQueue = DB::table('appointments')
        ->join('patients', 'appointments.patient_id', '=', 'patients.id')
        ->join('users as doctors', 'appointments.doctor_id', '=', 'doctors.id')
        ->whereDate('appointments.appointment_date', $today)
        ->select(
            'appointments.id as appointment_id',
            'patients.full_name as patient_name',
            'doctors.name as doctor_name',
            'appointments.appointment_time',
            'appointments.status'
        )
        ->orderBy('appointments.appointment_time', 'asc')
        ->get();

    $completedToday = DB::table('consultations')
        ->whereDate('created_at', $today)
        ->count();

    return response()->json([
        'summary' => [
            'total_money_collected_today' => (float) $totalMoney,
            'patients_waiting' => $patientsWaiting,
            'active_doctors' => $activeDoctors,
            'completed_today' => $completedToday,
        ],
        'financial_breakdown' => [
            'cash' => (float) ($paymentBreakdown['Cash'] ?? 0),
            'digital' => (float) ($paymentBreakdown['Digital'] ?? 0),
        ],
        'today_queue' => $todayQueue,
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

        public function getTodaysQueue(Request $request)
    {
        $today = \Carbon\Carbon::today()->toDateString();
        
        $query = DB::table('appointments')
            ->join('patients', 'appointments.patient_id', '=', 'patients.id')
            ->join('users', 'appointments.doctor_id', '=', 'users.id')
            ->where('appointments.appointment_date', $today)
            ->select(
                'appointments.id as appointment_id',
                'appointments.appointment_time',
                'patients.full_name as patient_name',
                'users.name as doctor_name',
                'appointments.status'
            )
            ->orderBy('appointments.appointment_time', 'asc');

        if ($request->user()->role === 'Doctor') {
            $query->where('appointments.doctor_id', $request->user()->id);
        }

        $queue = $query->get()->map(function($item) {
            return [
                'appointment_id' => $item->appointment_id,
                'time' => \Carbon\Carbon::parse($item->appointment_time)->format('g:i A'),
                'patient' => $item->patient_name,
                'doctor' => $item->doctor_name,
                'type' => 'General Checkup',
                'status' => $item->status == 'Confirmed' ? 'Waiting' : $item->status, 
            ];
        });

        return response()->json($queue);
        }

    public function updateQueueStatus(Request $request, $id)
{
    $request->validate([
        'status' => 'required|string|in:Pending,Confirmed,Cancelled',
    ]);

    $updated = DB::table('appointments')
        ->where('id', $id)
        ->update([
            'status' => $request->status,
            'updated_at' => Carbon::now(),
        ]);

    if (!$updated) {
        return response()->json([
            'status' => 'error',
            'message' => 'Appointment not found or no changes made.'
        ], 404);
    }

    return response()->json([
        'status' => 'success',
        'message' => 'Queue status updated successfully.',
        'appointment_id' => (int)$id,
        'new_status' => $request->status
    ]);
}

public function getDoctors()
{
    $doctors = DB::table('users')
        ->where('role', 'Doctor')
        ->select('id', 'name', 'email', 'role')
        ->get();

    return response()->json($doctors);
}



}