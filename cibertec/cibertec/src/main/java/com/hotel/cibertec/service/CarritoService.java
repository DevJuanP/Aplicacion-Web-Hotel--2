package com.hotel.cibertec.service;

import com.hotel.cibertec.dto.CarritoDto;
import java.util.List;

public interface CarritoService {

    // =========================
    // AHORA USA RECEPCIÓN
    // =========================
    Boolean agregarProducto(Integer idRecepcion, Integer idProducto, Integer cantidad);

    List<CarritoDto> obtenerCarritoPorRecepcion(Integer idRecepcion);

    void eliminarProducto(Integer idRecepcion, Integer idProducto);
}