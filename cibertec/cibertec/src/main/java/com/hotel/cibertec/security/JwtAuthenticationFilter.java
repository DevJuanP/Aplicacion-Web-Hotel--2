package com.hotel.cibertec.security;

import io.jsonwebtoken.ExpiredJwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final CustomUserDetailsService userDetailsService;

    public JwtAuthenticationFilter(
            JwtService jwtService,
            CustomUserDetailsService userDetailsService) {
        this.jwtService = jwtService;
        this.userDetailsService = userDetailsService;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain)
            throws ServletException, IOException {

        //Obtenemos el encabezado de autorización y verificamos el formato estándar "Bearer <token>"
        final String authHeader = request.getHeader("Authorization");

        //  Si no hay token, dejamos pasar la petición para que los filtros de seguridad
        // posteriores determinen si el endpoint requiere autenticación o no.
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            //  Eliminamos el prefijo "Bearer " (índice 0-6) para procesar solo el JWT
            final String jwt = authHeader.substring(7);
            final String correo = jwtService.extractUsername(jwt);

            // : Validamos que el token tenga un sujeto (correo) y que el usuario
            // aún no haya sido autenticado en el contexto actual de seguridad.
            if (correo != null &&
                    SecurityContextHolder.getContext().getAuthentication() == null) {

                //  Cargamos el usuario desde la BD para verificar su estado actual (habilitado/deshabilitado)
                UserDetails userDetails =
                        userDetailsService.loadUserByUsername(correo);

                //  Validamos la firma del token y la coincidencia con el usuario cargado
                if (jwtService.isTokenValid(jwt, userDetails.getUsername())) {

                    // Creamos el objeto de autenticación de Spring Security
                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(
                                    userDetails,
                                    null,
                                    userDetails.getAuthorities()
                            );

                    //  Añadimos detalles de la petición (ej. dirección IP) para trazabilidad
                    authToken.setDetails(
                            new WebAuthenticationDetailsSource()
                                    .buildDetails(request)
                    );

                    // Establecemos la autenticación en el contexto; a partir de aquí,
                    // el usuario es considerado "logueado" durante el resto de la petición.
                    SecurityContextHolder.getContext()
                            .setAuthentication(authToken);
                }
            }

        } catch (ExpiredJwtException e) {
            // Si el token está caducado, limpiamos el contexto para evitar acceso indebido
            SecurityContextHolder.clearContext();
        }

        //  Continuamos la ejecución de la cadena de filtros para llegar al controlador
        filterChain.doFilter(request, response);
    }
}