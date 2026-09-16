class_name AudioSynthHelper
extends RefCounted

## Gerador de Som Simples (Síntese Procedural em Memória)
## Cria um som de onda senoidal de 16 bits sem precisar de arquivos externos .wav

static func criar_som(frequencia: float = 440.0, duracao: float = 0.2) -> AudioStreamWAV:
	var taxa_amostragem = 22050 # 22.050 amostras por segundo (padrão de áudio digital)
	var total_amostras = int(taxa_amostragem * duracao)
	var dados = PackedByteArray()
	dados.resize(total_amostras * 2) # Cada amostra de 16 bits ocupa 2 bytes
	
	for i in range(total_amostras):
		var t = float(i) / float(taxa_amostragem) # Tempo decorrido em segundos
		var envelope = 1.0 - (float(i) / float(total_amostras)) # O som vai diminuindo até sumir
		
		# Fórmula matemática da onda senoidal: y(t) = sin(2 * PI * freq * t)
		var onda = sin(2.0 * PI * frequencia * t) * envelope * 0.5
		var valor_16bit = int(onda * 32000.0) # Converte de float [-1, 1] para inteiro de 16 bits
		
		dados.encode_s16(i * 2, valor_16bit)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = taxa_amostragem
	stream.stereo = false
	stream.data = dados
	return stream
