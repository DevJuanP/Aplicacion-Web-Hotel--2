// src/app/core/services/auth.service.ts
import { Injectable, inject, PLATFORM_ID } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { isPlatformBrowser } from '@angular/common'; // Importante para SSR
import { Observable, tap } from 'rxjs';
import { LoginRequest, LoginResponse } from '../models/auth.models';
import { ApiResponse } from '../models/ApiResponse';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private http = inject(HttpClient);
  private platformId = inject(PLATFORM_ID); // Inyectamos el ID de plataforma

  private readonly API_URL = 'http://localhost:8081/api/auth';
 private readonly TOKEN_KEY = 'token';
  private readonly ROLE_KEY = 'user_role';
  private readonly ID_KEY = 'user_id';

  login(credentials: LoginRequest): Observable<ApiResponse<LoginResponse>> {
    return this.http.post<ApiResponse<LoginResponse>>(`${this.API_URL}/login`, credentials)
      .pipe(
        tap(response => {
          // Solo accedemos al storage si estamos en el navegador
          if (isPlatformBrowser(this.platformId) && response.data.token) {
            localStorage.setItem(this.TOKEN_KEY, response.data.token);
            localStorage.setItem(this.ROLE_KEY, response.data.tipoPersona);
            localStorage.setItem(this.ROLE_KEY, response.data.tipoPersona);
            localStorage.setItem(this.ID_KEY, response.data.idPersona.toString());
          }
        })
      );
  }

  logout(): void {
    if (isPlatformBrowser(this.platformId)) {
      localStorage.removeItem(this.TOKEN_KEY);
      localStorage.removeItem(this.ROLE_KEY);
    }
  }

  getUserId(): string | null {
  if (isPlatformBrowser(this.platformId)) {
    return localStorage.getItem(this.ID_KEY);
  }
  return null;
}

  getToken(): string | null {
    if (isPlatformBrowser(this.platformId)) {
      return localStorage.getItem(this.TOKEN_KEY);
    }
    return null;
  }

  getUserRole(): string | null {
    if (isPlatformBrowser(this.platformId)) {
      return localStorage.getItem(this.ROLE_KEY);
    }
    return null;
  }

  isLoggedIn(): boolean {
    return !!this.getToken();
  }
}
