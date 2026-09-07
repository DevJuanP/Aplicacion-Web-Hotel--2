// src/app/core/interceptors/auth.interceptor.ts
import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';
import { catchError, throwError } from 'rxjs';
import { Router } from '@angular/router';

/**
 * Responsabilidad: Interceptor de peticiones HTTP.
 * Actúa como middleware global para inyectar credenciales y gestionar errores de autorización.
 */
export const authInterceptor: HttpInterceptorFn = (req, next) => {

  const authService = inject(AuthService);
  const router = inject(Router);

  const token = authService.getToken();

  // Validación: Exclusión de endpoints públicos para evitar inyectar headers innecesarios
  const isAuthEndpoint =
      req.url.includes('/api/auth/login') ||
      req.url.includes('/api/auth/register');

  let authReq = req;

  // Seguridad: Inyección del token JWT en el encabezado (Bearer Token)
  if (token && !isAuthEndpoint) {
    authReq = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`
      }
    });
  }

  // Flujo: Manejo centralizado de respuestas y errores
  return next(authReq).pipe(
    catchError((error: HttpErrorResponse) => {

      // Autorización: Si el Backend responde 401, el token expiró o es inválido.
      // Acción correctiva: Limpiar sesión y redirigir al login.
      if (error.status === 401) {
        authService.logout();
        router.navigate(['/login']);
      }

      return throwError(() => error);
    })
  );
};