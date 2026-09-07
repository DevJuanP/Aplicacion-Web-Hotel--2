package com.hotel.cibertec.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.function.Function;

/**
 * Servicio encargado de la gestión integral de tokens JWT:
 * creación, validación y extracción de información (claims).
 */
@Service
public class JwtService {

    private final SecretKey secretKey;
    private final long expirationTime;

    // Inyección de dependencias desde application.properties
    public JwtService(
            @Value("${jwt.secret}") String secret,
            @Value("${jwt.expiration}") long expiration) {

        this.expirationTime = expiration;

        /* * Seguridad en la clave (SecretKey).
         * HMAC requiere una clave de longitud mínima según el algoritmo (ej. HS256 requiere 32 bytes).
         * La lógica de fallback es una medida preventiva ante configuraciones débiles en el archivo properties.
         */
        if (secret == null || secret.trim().length() < 48) {
            String secureSecret = (secret + "A_SECURE_COMPLEMENT_LONG_ENOUGH_FOR_HS384_AND_HS512_AUTHENTICATION_CIBERTEC_HOTEL");
            this.secretKey = Keys.hmacShaKeyFor(secureSecret.getBytes(StandardCharsets.UTF_8));
        } else {
            this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        }
    }

    /**
     * Genera un nuevo token JWT para el usuario autenticado.
     */
    public String generateToken(String correo) {
        return Jwts.builder()
                .subject(correo) // El "subject" suele ser el identificador único (email/username)
                .issuedAt(new Date(System.currentTimeMillis())) // Fecha de emisión
                .expiration(new Date(System.currentTimeMillis() + expirationTime)) // Fecha de caducidad
                .signWith(secretKey) // Firma digital del token
                .compact();
    }

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    /**
     * Valida si el token pertenece al usuario y no ha expirado.
     */
    public boolean isTokenValid(String token, String correo) {
        final String username = extractUsername(token);
        return (username.equals(correo) && !isTokenExpired(token));
    }

    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    /**
     * Método genérico para extraer cualquier claim (información) del token.
     * Utiliza el patrón de diseño "Strategy" mediante Function<Claims, T>.
     */
    private <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    /**
     *  Parseo del token.
     * Aquí se verifica la integridad del token usando la clave secreta.
     * Si el token fue alterado, lanzará una excepción (ej. SignatureException).
     */
    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(secretKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}