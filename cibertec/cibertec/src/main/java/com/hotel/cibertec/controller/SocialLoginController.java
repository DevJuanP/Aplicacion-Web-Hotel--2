package com.hotel.cibertec.controller;

import com.hotel.cibertec.dto.*;
import com.hotel.cibertec.entity.Persona;
import com.hotel.cibertec.security.JwtService;
import com.hotel.cibertec.security.SocialAuthValidator;
import com.hotel.cibertec.service.SocialAuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class SocialLoginController {
    private final SocialAuthService socialAuthService;
    private final JwtService jwtService;
    private final SocialAuthValidator socialAuthValidator;

    @PostMapping("/social")
    public ResponseEntity<ApiResponse<LoginResponseDto>> socialLogin(@RequestBody SocialLoginRequestDto request) {

        // 1. Validación del Token
        if (!socialAuthValidator.isValidToken(request.getToken(), request.getProvider())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Token de autenticación externo no válido"));
        }

        // 2. Procesar Login (Registro o búsqueda)
        Persona persona = socialAuthService.processSocialLogin(
                request.getNombre(),
                request.getApellido(),
                request.getCorreo()
        );

        // 3. Generar token y mapear respuesta
        String token = jwtService.generateToken(persona.getCorreo());

        // Mapeo seguro del rol
        String nombreTipoPersona = (persona.getTipoPersona() != null)
                ? persona.getTipoPersona().getDescripcion() //  TipoPersonaDto
                : "Cliente";

        LoginResponseDto response = LoginResponseDto.builder()
                .idPersona(persona.getIdPersona())
                .nombre(persona.getNombre())
                .apellido(persona.getApellido())
                .correo(persona.getCorreo())
                .tipoPersona(nombreTipoPersona)
                .token(token)
                .build();

        return ResponseEntity.ok(ApiResponse.success("Login social exitoso", response));
    }
}