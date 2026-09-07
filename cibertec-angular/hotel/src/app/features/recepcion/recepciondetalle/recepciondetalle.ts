import { Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { forkJoin } from 'rxjs';
import Swal from 'sweetalert2';

// Servicios y Modelos
import { HabitacionService } from '../../../core/services/habitacion.service';
import { RecepcionService } from '../../../core/services/recepcion.service';
import { PersonaService } from '../../../core/services/persona.service';
import { CategoriaService } from '../../../core/services/categoria.service';
import { PisoService } from '../../../core/services/piso.service';
import { Habitacion } from '../../../core/models/Habitacion';
import { Persona } from '../../../core/models/persona.model';
import { Recepcion } from '../../../core/models/recepcion.model';

@Component({
  selector: 'app-recepciondetalle',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './recepciondetalle.html'
})
export class RecepcionDetalleComponent implements OnInit {
  // Inyección de dependencias
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly habService = inject(HabitacionService);
  private readonly recService = inject(RecepcionService);
  private readonly personaService = inject(PersonaService);
  private readonly catService = inject(CategoriaService);
  private readonly pisoService = inject(PisoService);

  // Estados reactivos (Signals)
  habitacion = signal<Habitacion | null>(null);
  recepcion = signal<Recepcion>(this.inicializarModelo());
  listaPersonas = signal<Persona[]>([]);
paginaActual = signal<number>(0);
itemsPorPagina = 5;
  // Mapas para catálogos descriptivos
  catMap = signal<Map<number, string>>(new Map());
  pisoMap = signal<Map<number, string>>(new Map());
esOcupada = computed(() => Number(this.habitacion()?.idEstadoHabitacion) === 2);
  // Estado UI
  noches = signal<number>(1);
  dniBusqueda = signal('');

  ngOnInit(): void {
    this.cargarCatalogos();
    this.cargarClientes();
    this.route.paramMap.subscribe(params => {
      const id = Number(params.get('id'));
      if (id) this.cargarDatos(id);
    });
  }

  private inicializarModelo(): Recepcion {
    const hoy = new Date().toISOString().split('T')[0];
    return {
      fechaEntrada: hoy,
      fechaSalida: hoy,
      precioInicial: 0,
      adelanto: 0,
      precioRestante: 0,
      totalPagado: 0,
      costoPenalidad: 0


    };
  }



  personasPaginadas = computed(() => {
  // Filtro extra de seguridad: solo los que tengan estado true
  const activos = this.listaPersonas().filter(p => p.estado === true);

  const inicio = this.paginaActual() * this.itemsPorPagina;
  return activos.slice(inicio, inicio + this.itemsPorPagina);
});

totalPaginas = computed(() => {
  const activos = this.listaPersonas().filter(p => p.estado === true);
  return Math.ceil(activos.length / this.itemsPorPagina);
});


// Métodos de navegación
cambiarPagina(nuevaPagina: number) {
  this.paginaActual.set(nuevaPagina);
}


  private obtenerHospedajeActivo(idHabitacion: number): void {
  this.recService.buscarActivaPorHabitacion(idHabitacion).subscribe({
    next: (res: any) => {
      // Si el backend ahora devuelve una lista, tomamos el primer elemento [0]
      // Si res.data es un array, tomamos el primero. Si es un objeto, lo usamos directo.
      const data = Array.isArray(res.data) ? res.data[0] : res.data;

      if (data) {
        this.recepcion.set(data);
        this.calcularTotal(); // Recalculamos al cargar los datos
      }
    },
    error: (err) => {
      console.error("Error al obtener hospedaje activo:", err);
      // Aquí puedes dejar que el usuario registre una nueva,
      // no es necesario lanzar un error bloqueante si no hay recepción activa.
    }
  });
}
  // --- Métodos para el Modal y UI ---
  abrirModalClientes(): void {
    const modalElement = document.getElementById('modalClientes');
    if (modalElement) {
      // Necesitas tener Bootstrap cargado en tu proyecto
      (window as any).bootstrap.Modal.getOrCreateInstance(modalElement).show();
    }
  }




  // --- Ajuste en cargarDatos para detectar ocupación ---
  cargarDatos(idHabitacion: number): void {
    this.habService.buscarPorId(idHabitacion).subscribe({
      next: (res) => {
        if (!res.data) return;
        this.habitacion.set(res.data);

        // Si está ocupada (idEstado 2), buscamos el detalle de la recepción actual
        if (this.esOcupada()) {
          this.obtenerHospedajeActivo(idHabitacion);
        } else {
          // Si está libre, inicializamos con precio base
          this.recepcion.update(r => ({
            ...r,
            idHabitacion,
            precioInicial: res.data.precio
          }));
        }
        this.calcularTotal();
      }
    });
  }
  // Carga de datos iniciales
  private cargarCatalogos(): void {
    forkJoin({
      cats: this.catService.listar(),
      pisos: this.pisoService.listar()
    }).subscribe(({ cats, pisos }) => {
      this.catMap.set(new Map((cats.data ?? []).map(c => [Number(c.idCategoria), c.descripcion])));
      this.pisoMap.set(new Map((pisos.data ?? []).map(p => [Number(p.idPiso), p.descripcion])));
    });
  }

private cargarClientes(): void {
  this.personaService.listar().subscribe({
    next: (res) => {
      // Filtramos por ID de tipo 3 (Clientes) Y estado activo (true)
      const clientesActivos = res?.data?.filter((p: Persona) =>
        Number(p.idTipoPersona) === 3 && p.estado === true
      ) || [];

      this.listaPersonas.set(clientesActivos);
    },
    error: (err) => {
      console.error("Error al cargar clientes:", err);
      Swal.fire('Error', 'No se pudieron cargar los clientes activos', 'error');
    }
  });
}

  // Lógica de cálculo reactivo
calcularTotal(): void {
  const hab = this.habitacion();
  if (!hab) return;

  // 1. Obtener fechas de la señal actual
  const entrada = new Date(this.recepcion().fechaEntrada!);
  const salida = new Date(this.recepcion().fechaSalida!);

  // 2. Cálculo de noches (similar a AlquilerComponente)
  // getTime() devuelve milisegundos. Usamos Math.ceil para redondear hacia arriba
  const diffTime = salida.getTime() - entrada.getTime();
  const diffDays = Math.max(0, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));

  // Actualizamos señal de noches
  this.noches.set(diffDays);

  // 3. Cálculo de montos
  const precioUnitario = hab.precio || 0;
  const totalCalculado = diffDays * precioUnitario;
  const adelanto = this.recepcion().adelanto || 0;

  // 4. Lógica de Restante y Total Pagado
  // Si adelanto >= total, se paga el total, restante es 0
  // Si adelanto < total, el restante es la diferencia
  const totalPagado = adelanto >= totalCalculado ? totalCalculado : adelanto;
  const precioRestante = Math.max(0, totalCalculado - adelanto);

  // 5. Actualizar la señal del modelo
  this.recepcion.update(r => ({
    ...r,
    precioInicial: totalCalculado,
    totalPagado: totalPagado,
    precioRestante: precioRestante
  }));
}
  // Acciones de registro
  guardar(): void {
    const data = this.recepcion();
    if (!data.idCliente) {
      Swal.fire('Error', 'Seleccione un cliente primero', 'error');
      return;
    }

    this.recService.registrar(data).subscribe({
      next: () => {
        Swal.fire('Éxito', 'Reservación registrada correctamente', 'success');
        this.router.navigate(['/admin/recepcion']);
      },
      error: (err) => Swal.fire('Error', err.error?.message ?? 'Error al guardar', 'error')
    });
  }

  // Helpers de búsqueda
  seleccionarPersona(c: Persona): void {
    this.recepcion.update(r => ({
      ...r,
      idCliente: c.idPersona,
      nombre: c.nombre,
      apellido: c.apellido,
      documento: c.documento,
      tipoDocumento: c.tipoDocumento,
      correo: c.correo
    }));
  }



  buscarCliente(): void {
  const busqueda = this.dniBusqueda().trim();
  const cliente = this.listaPersonas().find(p => p.documento?.toString().trim() === busqueda);

  if (cliente) {
    this.seleccionarPersona(cliente);
    // Swal opcional, quizás mejor quitarlo si el modal ya muestra la selección
  } else {
    Swal.fire('Atención', 'Cliente no encontrado en la lista de clientes', 'warning');
  }
}

  // Getters para la vista
  getCatNombre(id: number) { return this.catMap().get(Number(id)) ?? 'Cargando...'; }
  getPisoNombre(id: number) { return this.pisoMap().get(Number(id)) ?? 'Cargando...'; }
}
