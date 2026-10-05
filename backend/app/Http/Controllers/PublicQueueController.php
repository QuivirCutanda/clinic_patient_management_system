<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PublicQueueController extends Controller
{
    public function getPublicQueue()
    {
        $today = Carbon::today()->toDateString();

        $allWaiting = DB::table('appointments')
            ->join('patients', 'appointments.patient_id', '=', 'patients.id')
            ->join('users as doctors', 'appointments.doctor_id', '=', 'doctors.id')
            ->whereDate('appointments.appointment_date', $today)
            ->where('appointments.status', 'Waiting')
            ->select(
                'appointments.id as appointment_id',
                'patients.id as patient_id',
                'patients.full_name as patient_name',
                'doctors.name as doctor_name',
                'appointments.appointment_time',
                'appointments.status'
            )
            ->orderBy('appointments.appointment_time', 'asc')
            ->get();

        $consultationDesk = $allWaiting->first();
        $waitingArea = $allWaiting->slice(1)->values();

        $billingQuery = DB::table('consultations')
            ->join('patients', 'consultations.patient_id', '=', 'patients.id')
            ->leftJoin('billing', 'consultations.id', '=', 'billing.consultation_id')
            ->where(function ($query) {
                $query->whereNull('billing.status')
                    ->orWhere('billing.status', 'Unbilled');
            });

        if ($consultationDesk) {
            $billingQuery->where('consultations.patient_id', '!=', $consultationDesk->patient_id);
        }

        $billingArea = $billingQuery
            ->select(
                'consultations.id as consultation_id',
                'patients.full_name as patient_name',
                'billing.fee_amount',
                DB::raw("COALESCE(billing.status, 'Unbilled') as billing_status"),
                'consultations.created_at'
            )
            ->orderBy('consultations.created_at', 'asc')
            ->get();

        return response()->json([
            'waiting_area' => $waitingArea,
            'consultation_desk' => $consultationDesk ? [$consultationDesk] : [],
            'billing_area' => $billingArea
        ]);
    }
}