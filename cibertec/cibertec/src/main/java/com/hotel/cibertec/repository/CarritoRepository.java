package com.hotel.cibertec.repository;

import com.hotel.cibertec.entity.Carrito;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CarritoRepository extends JpaRepository<Carrito, Integer> {

    // =========================
    // AGREGAR AL CARRITO
    // =========================
    @Query(value = "SELECT fn_agregaralcarrito(:idRecepcion, :idProducto, :cantidad)", nativeQuery = true)
    Boolean agregarAlCarrito(@Param("idRecepcion") Integer idRecepcion,
                             @Param("idProducto") Integer idProducto,
                             @Param("cantidad") Integer cantidad);

    // =========================
    // LISTAR POR RECEPCIÓN
    // =========================
    @Query("SELECT c FROM Carrito c JOIN FETCH c.producto WHERE c.recepcion.idRecepcion = :idRecepcion")
    List<Carrito> findByRecepcion_IdRecepcion(@Param("idRecepcion") Integer idRecepcion);

    // =========================
    // ELIMINAR PRODUCTO
    // =========================
    @Modifying
    @Query("DELETE FROM Carrito c WHERE c.recepcion.idRecepcion = :idRecepcion AND c.producto.idProducto = :idProducto")
    void deleteByRecepcion_IdRecepcionAndProducto_IdProducto(@Param("idRecepcion") Integer idRecepcion,
                                                             @Param("idProducto") Integer idProducto);
}