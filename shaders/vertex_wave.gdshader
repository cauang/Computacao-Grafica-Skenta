shader_type spatial;

uniform float velocidade : hint_range(0.1, 5.0) = 2.0;
uniform float altura_onda : hint_range(0.0, 1.0) = 0.2;

void vertex() {
	// COMPUTACAO GRAFICA: Modificação geométrica no Vertex Shader
	// Altera a altura Y dos vértices usando uma função seno baseada na posição X e no tempo
	VERTEX.y += sin(VERTEX.x * 3.0 + TIME * velocidade) * altura_onda;
}

void fragment() {
	// Cor avermelhada metálica
	ALBEDO = vec3(0.9, 0.2, 0.3);
	ROUGHNESS = 0.2;
	METALLIC = 0.8;
}
