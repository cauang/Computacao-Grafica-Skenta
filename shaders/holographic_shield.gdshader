shader_type spatial;
render_mode blend_add, cull_disabled;

// Parâmetros configuráveis
uniform vec4 cor_base : source_color = vec4(0.1, 0.6, 1.0, 1.0);
uniform float forca_fresnel : hint_range(1.0, 5.0) = 2.5;

void fragment() {
	// COMPUTACAO GRAFICA: Efeito Fresnel
	// Mede o produto escalar entre o vetor Normal (NORMAL) e a direção da câmera (VIEW)
	// dot = 1.0 quando a superfície está de frente para a câmera
	// dot = 0.0 quando a superfície está de lado (nas bordas rasantes)
	float produto_escalar = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float fresnel = pow(1.0 - produto_escalar, forca_fresnel);

	// Define as propriedades de cor na GPU
	ALBEDO = cor_base.rgb;
	EMISSION = cor_base.rgb * fresnel * 2.0; // Brilho intenso nas bordas
	ALPHA = clamp(fresnel * 1.5, 0.1, 0.9);   // Borda opaca, centro transparente
}
