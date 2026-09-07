package com.hotel.cibertec.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "HABITACION")
public class Habitacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idhabitacion")
    private Integer idHabitacion;

    @Column(name = "numero", nullable = false, unique = true)
    private String numero;

    @Column(name = "detalle")
    private String detalle;

    @Column(name = "precio", precision = 10, scale = 2)
    private BigDecimal precio;

    @ManyToOne(fetch = FetchType.LAZY) // <--- Mejora de rendimiento
    @JoinColumn(name = "idestadohabitacion")
    private EstadoHabitacion estadoHabitacion;

    @ManyToOne(fetch = FetchType.LAZY) // <--- Mejora de rendimiento
    @JoinColumn(name = "idpiso")
    private Piso piso;

    @ManyToOne(fetch = FetchType.LAZY) // <--- Mejora de rendimiento
    @JoinColumn(name = "idcategoria")
    private Categoria categoria;

    @OneToMany(mappedBy = "habitacion", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<ImagenHabitacion> imagenes;

    // Asignamos valor por defecto para evitar Nulos
    @Column(name = "estado", nullable = false)

    private Boolean estado = true;

    @Column(name = "fechacreacion")
    private LocalDateTime fechaCreacion = LocalDateTime.now();

    @JsonIgnore
    @OneToMany(mappedBy = "habitacion")
    private List<Recepcion> recepciones;

    // Hook para establecer fecha antes de persistir
    @PrePersist
    protected void onCreate() {
        if (this.fechaCreacion == null) {
            this.fechaCreacion = LocalDateTime.now();
        }
    }
}