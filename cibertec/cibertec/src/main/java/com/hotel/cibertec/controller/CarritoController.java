package com.hotel.cibertec.controller;

import com.hotel.cibertec.dto.CarritoDto;
import com.hotel.cibertec.service.CarritoService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/carrito")
public class CarritoController {

    private final CarritoService carritoService;

    public CarritoController(CarritoService carritoService) {
        this.carritoService = carritoService;
    }

    @PostMapping("/agregar")
    public ResponseEntity<?> agregarProducto(
            @RequestParam Integer idRecepcion,
            @RequestParam Integer idProducto,
            @RequestParam Integer cantidad) {

        try {
            Boolean resultado = carritoService.agregarProducto(idRecepcion, idProducto, cantidad);

            if (resultado) {
                return ResponseEntity.ok("Producto agregado correctamente.");
            }

            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body("Error: Stock insuficiente o recepción inválida.");

        } catch (RuntimeException e) {
            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .body(e.getMessage());
        }
    }

    @GetMapping("/listar/{idRecepcion}")
    public ResponseEntity<?> obtenerCarrito(@PathVariable Integer idRecepcion) {

        try {
            List<CarritoDto> carrito = carritoService.obtenerCarritoPorRecepcion(idRecepcion);
            return ResponseEntity.ok(carrito);

        } catch (RuntimeException e) {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(e.getMessage());
        }
    }

    @DeleteMapping("/eliminar")
    public ResponseEntity<?> eliminarProducto(
            @RequestParam Integer idRecepcion,
            @RequestParam Integer idProducto) {

        try {
            carritoService.eliminarProducto(idRecepcion, idProducto);
            return ResponseEntity.noContent().build();

        } catch (RuntimeException e) {
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(e.getMessage());
        }
    }
}