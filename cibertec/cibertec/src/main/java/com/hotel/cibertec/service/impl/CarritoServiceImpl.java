package com.hotel.cibertec.service.impl;

import com.hotel.cibertec.dto.CarritoDto;
import com.hotel.cibertec.entity.Recepcion;
import com.hotel.cibertec.repository.CarritoRepository;
import com.hotel.cibertec.repository.RecepcionRepository;
import com.hotel.cibertec.service.CarritoService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CarritoServiceImpl implements CarritoService {

    private final CarritoRepository carritoRepository;
    private final RecepcionRepository recepcionRepository;

    public CarritoServiceImpl(CarritoRepository carritoRepository,
                              RecepcionRepository recepcionRepository) {
        this.carritoRepository = carritoRepository;
        this.recepcionRepository = recepcionRepository;
    }

    // =========================
    // AGREGAR PRODUCTO
    // =========================
    @Override
    @Transactional
    public Boolean agregarProducto(Integer idRecepcion, Integer idProducto, Integer cantidad) {

        recepcionRepository.findById(idRecepcion)
                .orElseThrow(() -> new RuntimeException(
                        "No existe la recepción seleccionada."
                ));

        return carritoRepository.agregarAlCarrito(idRecepcion, idProducto, cantidad);
    }

    // =========================
    // OBTENER CARRITO
    // =========================
    @Override
    @Transactional(readOnly = true)
    public List<CarritoDto> obtenerCarritoPorRecepcion(Integer idRecepcion) {

        Recepcion recepcion = recepcionRepository.findById(idRecepcion)
                .orElseThrow(() -> new RuntimeException(
                        "La recepción no existe o no está activa."
                ));

        return carritoRepository.findByRecepcion_IdRecepcion(idRecepcion)
                .stream()
                .map(c -> CarritoDto.builder()
                        .idCarrito(c.getIdCarrito())
                        .idRecepcion(c.getRecepcion().getIdRecepcion())
                        .idPersona(c.getRecepcion().getCliente().getIdPersona())
                        .idProducto(c.getProducto().getIdProducto())
                        .nombreProducto(c.getProducto().getNombre())
                        .precioUnitario(c.getProducto().getPrecio())
                        .imagenUrl(c.getProducto().getImagenUrl())
                        .cantidad(c.getCantidad())
                        .fechaRegistro(c.getFechaRegistro())
                        .build())
                .collect(Collectors.toList());
    }

    // =========================
    // ELIMINAR PRODUCTO
    // =========================
    @Override
    @Transactional
    public void eliminarProducto(Integer idRecepcion, Integer idProducto) {

        recepcionRepository.findById(idRecepcion)
                .orElseThrow(() -> new RuntimeException(
                        "Operación no permitida: recepción inválida."
                ));

        carritoRepository.deleteByRecepcion_IdRecepcionAndProducto_IdProducto(
                idRecepcion,
                idProducto
        );
    }
}