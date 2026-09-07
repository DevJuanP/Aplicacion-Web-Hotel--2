package com.hotel.cibertec.service.impl;

import com.hotel.cibertec.dto.RecepcionDto;
import com.hotel.cibertec.entity.Recepcion;
import com.hotel.cibertec.repository.RecepcionRepository;
import com.hotel.cibertec.service.RecepcionService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.ParameterMode;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.StoredProcedureQuery;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RecepcionServiceImpl implements RecepcionService {

    private final RecepcionRepository repository;

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    @Transactional(readOnly = true)
    public List<RecepcionDto> listarTodos() {
        return repository.findAll()
                .stream()
                .map(this::toDtoConDatosCliente)
                .collect(Collectors.toList());
    }

    /**
     * IMPORTANTE: Se utiliza findByIdWithDetails del repositorio para cargar
     * mediante LEFT JOIN FETCH todas las relaciones necesarias en una sola consulta SQL.
     */
    @Override
    @Transactional(readOnly = true)
    public RecepcionDto buscarPorId(Integer id) {
        return repository.findByIdWithDetails(id)
                .map(this::toDtoConDatosCliente)
                .orElseThrow(() -> new RuntimeException("Registro de recepción no encontrado con ID: " + id));
    }


    @Override
    @Transactional(readOnly = true)
    public RecepcionDto buscarActivaPorHabitacion(Integer idHabitacion) {
        List<Recepcion> lista = repository.findByHabitacionIdAndEstadoWithDetails(idHabitacion, true);

        if (lista == null || lista.isEmpty()) {
            throw new RuntimeException("No se encontró ninguna recepción activa para esta habitación");
        }

        return toDtoConDatosCliente(lista.get(0));
    }

    @Override
    @Transactional
    public RecepcionDto guardar(RecepcionDto dto) {
        StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_RegistrarRecepcion");

        query.registerStoredProcedureParameter("p_IdCliente", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_TipoDocumento", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_Documento", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_Nombre", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_Apellido", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_Correo", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_IdHabitacion", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_FechaSalida", java.sql.Date.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_PrecioInicial", java.math.BigDecimal.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_Adelanto", java.math.BigDecimal.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_PrecioRestante", java.math.BigDecimal.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_Observacion", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Resultado", Boolean.class, ParameterMode.OUT);

        // Asignación de valores
        query.setParameter("p_IdCliente", dto.getIdCliente() != null ? dto.getIdCliente() : 0);
        query.setParameter("p_TipoDocumento", dto.getTipoDocumento());
        query.setParameter("p_Documento", dto.getDocumento());
        query.setParameter("p_Nombre", dto.getNombre());
        query.setParameter("p_Apellido", dto.getApellido());
        query.setParameter("p_Correo", dto.getCorreo());
        query.setParameter("p_IdHabitacion", dto.getIdHabitacion());
        query.setParameter("p_FechaSalida", dto.getFechaSalida() != null ? java.sql.Date.valueOf(dto.getFechaSalida()) : null);
        query.setParameter("p_PrecioInicial", dto.getPrecioInicial() != null ? dto.getPrecioInicial() : java.math.BigDecimal.ZERO);
        query.setParameter("p_Adelanto", dto.getAdelanto() != null ? dto.getAdelanto() : java.math.BigDecimal.ZERO);
        query.setParameter("p_PrecioRestante", dto.getPrecioRestante() != null ? dto.getPrecioRestante() : java.math.BigDecimal.ZERO);
        query.setParameter("p_Observacion", dto.getObservacion());

        query.execute();

        Boolean resultado = (Boolean) query.getOutputParameterValue("Resultado");
        if (Boolean.TRUE.equals(resultado)) {
            return buscarActivaPorHabitacion(dto.getIdHabitacion());
        } else {
            throw new RuntimeException("Error: El procedimiento almacenado no pudo completar el registro.");
        }
    }



    @Override
    @Transactional
    public RecepcionDto actualizar(Integer id, RecepcionDto dto) {
        Recepcion recepcion = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Registro no encontrado"));

        recepcion.setFechaSalidaConfirmacion(dto.getFechaSalidaConfirmacion());
        recepcion.setTotalPagado(dto.getTotalPagado());
        recepcion.setCostoPenalidad(dto.getCostoPenalidad());
        recepcion.setEstado(dto.getEstado());

        return toDto(repository.save(recepcion));
    }

    @Override
    @Transactional
    public Boolean procesarSalida(Integer idRecepcion, Integer idHabitacion, BigDecimal penalidad, BigDecimal total) {
        StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_RegistrarSalida");

        query.registerStoredProcedureParameter("p_IdRecepcion", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_IdHabitacion", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_CostoPenalidad", BigDecimal.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_TotalPagado", BigDecimal.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("p_Resultado", Boolean.class, ParameterMode.OUT);

        query.setParameter("p_IdRecepcion", idRecepcion);
        query.setParameter("p_IdHabitacion", idHabitacion);
        query.setParameter("p_CostoPenalidad", penalidad);
        query.setParameter("p_TotalPagado", total);

        query.execute();

        Boolean resultado = (Boolean) query.getOutputParameterValue("p_Resultado");

        entityManager.flush();
        entityManager.clear();

        if (resultado == null || !resultado) {
            throw new RuntimeException("No se pudo completar el check-out.");
        }

        return true;
    }


    @Override
    @Transactional
    public void eliminar(Integer id) {
        Recepcion recepcion = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Registro no encontrado"));
        recepcion.setEstado(false);
        repository.save(recepcion);
    }

    private RecepcionDto toDto(Recepcion entity) {
        RecepcionDto dto = RecepcionDto.builder()
                .idRecepcion(entity.getIdRecepcion())
                .idCliente(entity.getCliente() != null ? entity.getCliente().getIdPersona() : null)
                .idHabitacion(entity.getHabitacion() != null ? entity.getHabitacion().getIdHabitacion() : null)
                .fechaEntrada(entity.getFechaEntrada())
                .fechaSalida(entity.getFechaSalida())
                .fechaSalidaConfirmacion(entity.getFechaSalidaConfirmacion())
                .observacion(entity.getObservacion())
                .estado(entity.getEstado())
                .build();

        dto.setPrecioInicial(entity.getPrecioInicial() != null ? entity.getPrecioInicial() : BigDecimal.ZERO);
        dto.setAdelanto(entity.getAdelanto() != null ? entity.getAdelanto() : BigDecimal.ZERO);
        dto.setPrecioRestante(entity.getPrecioRestante() != null ? entity.getPrecioRestante() : BigDecimal.ZERO);
        dto.setTotalPagado(entity.getTotalPagado() != null ? entity.getTotalPagado() : BigDecimal.ZERO);
        dto.setCostoPenalidad(entity.getCostoPenalidad() != null ? entity.getCostoPenalidad() : BigDecimal.ZERO);

        return dto;
    }


    private RecepcionDto toDtoConDatosCliente(Recepcion entity) {
        RecepcionDto dto = toDto(entity);

        if (entity.getCliente() != null) {
            dto.setNombre(entity.getCliente().getNombre() != null ? entity.getCliente().getNombre() : "N/A");
            dto.setApellido(entity.getCliente().getApellido() != null ? entity.getCliente().getApellido() : "");
            dto.setDocumento(entity.getCliente().getDocumento() != null ? entity.getCliente().getDocumento() : "S/D");
            dto.setTipoDocumento(entity.getCliente().getTipoDocumento() != null ? entity.getCliente().getTipoDocumento() : "N/A");
            dto.setCorreo(entity.getCliente().getCorreo() != null ? entity.getCliente().getCorreo() : "N/A");
        } else {
            dto.setNombre("Cliente Desconocido");
        }

        // Manejo seguro de habitación
        if (entity.getHabitacion() != null) {
            dto.setNumero(entity.getHabitacion().getNumero() != null ? entity.getHabitacion().getNumero() : "000");
            dto.setDetalleHabitacion(entity.getHabitacion().getDetalle() != null ? entity.getHabitacion().getDetalle() : "");
            dto.setPrecioHabitacion(entity.getHabitacion().getPrecio() != null ? entity.getHabitacion().getPrecio() : BigDecimal.ZERO);

            // Uso de operadores ternarios para evitar nulos en sub-objetos
            dto.setEstadoHabitacion(entity.getHabitacion().getEstadoHabitacion() != null ?
                    entity.getHabitacion().getEstadoHabitacion().getDescripcion() : "Sin Estado");

            dto.setCategoriaNombre(entity.getHabitacion().getCategoria() != null ?
                    entity.getHabitacion().getCategoria().getDescripcion() : "Sin Categoría");

            dto.setPisoNombre(entity.getHabitacion().getPiso() != null ?
                    entity.getHabitacion().getPiso().getDescripcion() : "Sin Piso");
        } else {
            dto.setNumero("Sin Asignar");
        }

        return dto;
    }

    @Override
    @Transactional(readOnly = true)
    public List<RecepcionDto> listarPorCliente(Integer idCliente) {
        return repository.findByClienteIdAndEstadoWithDetails(idCliente, true)
                .stream()
                .map(this::toDtoConDatosCliente)
                .collect(Collectors.toList());
    }
}
