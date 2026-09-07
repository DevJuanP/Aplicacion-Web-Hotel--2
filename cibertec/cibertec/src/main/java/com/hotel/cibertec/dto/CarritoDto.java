package com.hotel.cibertec.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CarritoDto {
    private Integer idCarrito;
    private Integer idRecepcion;
    private Integer idPersona;
    private Integer idProducto;

    private String nombreProducto;
    private BigDecimal precioUnitario;
    private String imagenUrl;
    private Integer cantidad;
    private LocalDateTime fechaRegistro;

    public BigDecimal getSubtotal() {
        if (this.precioUnitario != null && this.cantidad != null) {
            return this.precioUnitario.multiply(BigDecimal.valueOf(this.cantidad));
        }
        return BigDecimal.ZERO;
    }
}