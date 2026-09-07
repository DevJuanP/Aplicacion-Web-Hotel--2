package com.hotel.cibertec.repository;

import com.hotel.cibertec.entity.Recepcion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface RecepcionRepository extends JpaRepository<Recepcion, Integer> {

    @Query("SELECT r FROM Recepcion r " +
            "LEFT JOIN FETCH r.cliente " +
            "LEFT JOIN FETCH r.habitacion h " +
            "LEFT JOIN FETCH h.categoria " +
            "LEFT JOIN FETCH h.piso " +
            "LEFT JOIN FETCH h.estadoHabitacion " +
            "WHERE r.idRecepcion = :id")
    Optional<Recepcion> findByIdWithDetails(@Param("id") Integer id);

    @Query("SELECT r FROM Recepcion r " +
            "LEFT JOIN FETCH r.cliente " +
            "LEFT JOIN FETCH r.habitacion h " +
            "LEFT JOIN FETCH h.categoria " +
            "LEFT JOIN FETCH h.piso " +
            "LEFT JOIN FETCH h.estadoHabitacion " +
            "WHERE h.idHabitacion = :idHabitacion AND r.estado = :estado " +
            "ORDER BY r.fechaEntrada DESC")
    List<Recepcion> findByHabitacionIdAndEstadoWithDetails(
            @Param("idHabitacion") Integer idHabitacion,
            @Param("estado") Boolean estado);

    @Query("SELECT r FROM Recepcion r WHERE r.cliente.idPersona = :idCliente AND r.estado = true")
    Optional<Recepcion> findByIdClienteAndEstadoTrue(@Param("idCliente") Integer idCliente);
//detalles de reserva cliente
    @Query("SELECT r FROM Recepcion r " +
            "LEFT JOIN FETCH r.cliente " +
            "LEFT JOIN FETCH r.habitacion h " +
            "LEFT JOIN FETCH h.categoria " +
            "LEFT JOIN FETCH h.piso " +
            "LEFT JOIN FETCH h.estadoHabitacion " +
            "WHERE r.cliente.idPersona = :idCliente AND r.estado = :estado")
    List<Recepcion> findByClienteIdAndEstadoWithDetails(
            @Param("idCliente") Integer idCliente,
            @Param("estado") Boolean estado);

}