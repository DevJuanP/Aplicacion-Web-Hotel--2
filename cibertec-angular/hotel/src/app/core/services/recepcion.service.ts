import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { ApiResponse } from '../models/ApiResponse';
import { Recepcion } from '../models/recepcion.model';

@Injectable({ providedIn: 'root' })
export class RecepcionService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = 'http://localhost:8081/api/recepcion';

  listar(): Observable<ApiResponse<Recepcion[]>> {
    return this.http.get<ApiResponse<Recepcion[]>>(`${this.baseUrl}/listar`).pipe(
      tap(res => {
        if (res.data) {
          res.data = res.data.filter((item: any) => item.idRecepcion !== undefined);
        }
      })
    );
  }

  // Nuevo método para listar reservas por cliente
  listarPorCliente(idCliente: number): Observable<ApiResponse<Recepcion[]>> {
    return this.http.get<ApiResponse<Recepcion[]>>(`${this.baseUrl}/cliente/${idCliente}`);
  }

  registrar(dto: Recepcion): Observable<ApiResponse<Recepcion>> {
    return this.http.post<ApiResponse<Recepcion>>(`${this.baseUrl}/registrar`, dto);
  }

  registrarSalida(data: any): Observable<ApiResponse<boolean>> {
    return this.http.post<ApiResponse<boolean>>(`${this.baseUrl}/registrar-salida`, data);
  }

  buscarPorId(id: number): Observable<ApiResponse<Recepcion>> {
    return this.http.get<ApiResponse<Recepcion>>(`${this.baseUrl}/${id}`);
  }

  buscarActivaPorHabitacion(idHabitacion: number): Observable<ApiResponse<Recepcion>> {
    return this.http.get<ApiResponse<Recepcion>>(`${this.baseUrl}/habitacion-activa/${idHabitacion}`);
  }

  actualizar(id: number, dto: Recepcion): Observable<ApiResponse<Recepcion>> {
    return this.http.put<ApiResponse<Recepcion>>(`${this.baseUrl}/actualizar/${id}`, dto);
  }

  eliminar(id: number): Observable<ApiResponse<null>> {
    return this.http.delete<ApiResponse<null>>(`${this.baseUrl}/eliminar/${id}`);
  }
}
