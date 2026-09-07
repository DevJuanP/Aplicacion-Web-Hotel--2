package com.hotel.cibertec.controller;

import com.hotel.cibertec.dto.ApiResponse;
import com.hotel.cibertec.dto.RecepcionDto;
import com.hotel.cibertec.exception.BusinessException;
import com.hotel.cibertec.service.RecepcionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/recepcion")
@RequiredArgsConstructor
@Slf4j
public class RecepcionController {

    private final RecepcionService service;

    @GetMapping("/habitacion-activa/{idHabitacion}")
    public ResponseEntity<ApiResponse<?>> buscarActivaPorHabitacion(@PathVariable Integer idHabitacion) {
        log.info("Consultando recepción activa para habitación ID: {}", idHabitacion);
        var resultado = service.buscarActivaPorHabitacion(idHabitacion);
        return ResponseEntity.ok(ApiResponse.success(resultado));
    }

    @GetMapping("/listar")
    public ResponseEntity<ApiResponse<?>> listar() {
        return ResponseEntity.ok(ApiResponse.success(service.listarTodos()));
    }

    @PostMapping("/registrar-salida")
    public ResponseEntity<ApiResponse<?>> registrarSalida(@RequestBody Map<String, Object> payload) {
        log.info("Procesando salida con payload: {}", payload);

        // Extracción segura de valores
        Integer idRecepcion = Optional.ofNullable(payload.get("idRecepcion"))
                .map(obj -> Integer.parseInt(obj.toString()))
                .orElseThrow(() -> new BusinessException("ID de recepción es requerido"));

        Integer idHabitacion = Optional.ofNullable(payload.get("idHabitacion"))
                .map(obj -> Integer.parseInt(obj.toString()))
                .orElseThrow(() -> new BusinessException("ID de habitación es requerido"));

        BigDecimal penalidad = new BigDecimal(payload.getOrDefault("costoPenalidad", "0").toString());
        BigDecimal total = new BigDecimal(payload.getOrDefault("totalPagado", "0").toString());

        if (service.procesarSalida(idRecepcion, idHabitacion, penalidad, total)) {
            return ResponseEntity.ok(ApiResponse.success("Salida procesada con éxito"));
        }

        throw new BusinessException("No se pudo procesar la salida. Verifique los datos enviados.");
    }

    @PostMapping("/registrar")
    public ResponseEntity<ApiResponse<?>> registrar(@Valid @RequestBody RecepcionDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(service.guardar(dto)));
    }

    @PutMapping("/actualizar/{id}")
    public ResponseEntity<ApiResponse<?>> actualizar(@PathVariable Integer id, @Valid @RequestBody RecepcionDto dto) {
        return ResponseEntity.ok(ApiResponse.success(service.actualizar(id, dto)));
    }

    // Este método es el que causaba el error 500 anteriormente
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> obtenerPorId(@PathVariable Integer id) {
        log.info("Buscando recepción con ID: {}", id);
        // Llamamos al servicio que implementaste
        RecepcionDto resultado = service.buscarPorId(id);
        return ResponseEntity.ok(ApiResponse.success(resultado));
    }

    @DeleteMapping("/eliminar/{id}")
    public ResponseEntity<ApiResponse<?>> eliminar(@PathVariable Integer id) {
        service.eliminar(id);
        return ResponseEntity.ok(ApiResponse.success("Registro eliminado correctamente"));
    }

    @GetMapping("/cliente/{idCliente}")
    public ResponseEntity<ApiResponse<?>> listarPorCliente(@PathVariable Integer idCliente) {
        log.info("Consultando recepciones activas para cliente ID: {}", idCliente);
        var resultado = service.listarPorCliente(idCliente);
        return ResponseEntity.ok(ApiResponse.success(resultado));
    }
}  