<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Patient extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'email',
        'password',
        'full_name',
        'contact_number',
        'emergency_contact',
        'insurance_provider',
        'date_of_birth',
        'sex',
        'address',
        'blood_type',
        'allergies',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];
}