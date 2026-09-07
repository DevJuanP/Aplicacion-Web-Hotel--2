package com.hotel.cibertec.dto;

import lombok.*;
import java.math.BigDecimal;
import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class VentaDto {
    private Integer idVenta;
    private Integer idRecepcion;
    private BigDecimal total;
    private String estado;
    private List<DetalleVentaDto> detalles;
}




