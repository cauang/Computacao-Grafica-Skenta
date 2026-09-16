extends Node3D
const AudioSynthHelper = preload("res://scripts/audio_synth_helper.gd")


signal vida_alterada(atual: float, maxima: float)
signal pontos_alterados(novos_pontos: int)

var vida_maxima: float = 100.0
var vida_atual: float = 100.0
var pontos: int = 0

@onready var pivo_camera: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

@onready var esfera_pbr: MeshInstance3D = $Objects/PBRSphere
@onready var esfera_shader: MeshInstance3D = $Objects/ShaderSphere
@onready var orbe_audio: Node3D = $Objects/AudioBeacon
@onready var reprodutor_3d: AudioStreamPlayer3D = $Objects/AudioBeacon/AudioStreamPlayer3D
@onready var reprodutor_2d: AudioStreamPlayer = $AudioStreamPlayer2D

@onready var barra_vida: ProgressBar = $HUD/MarginContainer/VBoxTop/HealthContainer/GhostLayer/HealthBar
@onready var barra_fantasma: ProgressBar = $HUD/MarginContainer/VBoxTop/HealthContainer/GhostLayer/DamageGhostBar
@onready var texto_vida: Label = $HUD/MarginContainer/VBoxTop/HealthContainer/HealthLabel
@onready var texto_pontos: Label = $HUD/MarginContainer/VBoxTop/ScoreContainer/ScoreLabel

@onready var deslizador_metalico: HSlider = $HUD/ControlPanel/VBox/TabContainer/Materiais/HBoxMetallic/SliderMetallic
@onready var deslizador_rugosidade: HSlider = $HUD/ControlPanel/VBox/TabContainer/Materiais/HBoxRoughness/SliderRoughness
@onready var rotulo_metalico: Label = $HUD/ControlPanel/VBox/TabContainer/Materiais/HBoxMetallic/ValLabel
@onready var rotulo_rugosidade: Label = $HUD/ControlPanel/VBox/TabContainer/Materiais/HBoxRoughness/ValLabel

var som_dano: AudioStreamWAV
var som_moeda: AudioStreamWAV
var som_3d: AudioStreamWAV

var rotacao_x: float = -0.3
var rotacao_y: float = 0.5
var distancia_camera: float = 8.0
var arrastando_mouse: bool = false
var posicao_anterior_mouse: Vector2 = Vector2.ZERO

func _ready() -> void:
	som_dano = AudioSynthHelper.criar_som(150.0, 0.25)
	som_moeda = AudioSynthHelper.criar_som(880.0, 0.2)
	som_3d = AudioSynthHelper.criar_som(440.0, 0.3)
	reprodutor_3d.stream = som_3d
	
	vida_alterada.connect(_ao_mudar_vida)
	pontos_alterados.connect(_ao_mudar_pontos)
	
	vida_alterada.emit(vida_atual, vida_maxima)
	pontos_alterados.emit(pontos)
	
	_atualizar_camera()

func _process(delta: float) -> void:
	if orbe_audio: orbe_audio.rotate_y(delta * 1.5)
	if esfera_shader: esfera_shader.rotate_y(delta * 0.8)
	if esfera_pbr: esfera_pbr.rotate_y(delta * 0.4)

func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton:
		if evento.button_index == MOUSE_BUTTON_LEFT or evento.button_index == MOUSE_BUTTON_RIGHT:
			arrastando_mouse = evento.pressed
			posicao_anterior_mouse = evento.position
		elif evento.button_index == MOUSE_BUTTON_WHEEL_UP:
			distancia_camera = clamp(distancia_camera - 0.5, 3.0, 16.0)
			_atualizar_camera()
		elif evento.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distancia_camera = clamp(distancia_camera + 0.5, 3.0, 16.0)
			_atualizar_camera()
	elif evento is InputEventMouseMotion and arrastando_mouse:
		var diferenca = evento.position - posicao_anterior_mouse
		posicao_anterior_mouse = evento.position
		rotacao_y -= diferenca.x * 0.005
		rotacao_x = clamp(rotacao_x - diferenca.y * 0.005, -1.2, 0.2)
		_atualizar_camera()

func _atualizar_camera() -> void:
	pivo_camera.rotation = Vector3(rotacao_x, rotacao_y, 0.0)
	camera.position = Vector3(0.0, 0.0, distancia_camera)

func _ao_alterar_metalico(valor: float) -> void:
	var material = esfera_pbr.get_active_material(0) as StandardMaterial3D
	material.metallic = valor
	rotulo_metalico.text = "%.2f" % valor

func _ao_alterar_rugosidade(valor: float) -> void:
	var material = esfera_pbr.get_active_material(0) as StandardMaterial3D
	material.roughness = valor
	rotulo_rugosidade.text = "%.2f" % valor

func _ao_clicar_ouro() -> void:
	var material = esfera_pbr.get_active_material(0) as StandardMaterial3D
	material.albedo_color = Color(1.0, 0.84, 0.0)
	material.metallic = 1.0
	material.roughness = 0.15
	deslizador_metalico.value = 1.0
	deslizador_rugosidade.value = 0.15

func _ao_clicar_plastico() -> void:
	var material = esfera_pbr.get_active_material(0) as StandardMaterial3D
	material.albedo_color = Color(0.9, 0.15, 0.15)
	material.metallic = 0.0
	material.roughness = 0.4
	deslizador_metalico.value = 0.0
	deslizador_rugosidade.value = 0.4

func _ao_clicar_esmeralda() -> void:
	var material = esfera_pbr.get_active_material(0) as StandardMaterial3D
	material.albedo_color = Color(0.08, 0.85, 0.45)
	material.metallic = 0.2
	material.roughness = 0.05
	deslizador_metalico.value = 0.2
	deslizador_rugosidade.value = 0.05

func _ao_tocar_som_3d() -> void:
	reprodutor_3d.play()
	var malha_orbe = $Objects/AudioBeacon/BeaconOrb
	var transicao = create_tween()
	transicao.tween_property(malha_orbe, "scale", Vector3(1.4, 1.4, 1.4), 0.1)
	transicao.tween_property(malha_orbe, "scale", Vector3(1.0, 1.0, 1.0), 0.2)

func _ao_tocar_som_2d() -> void:
	reprodutor_2d.stream = som_moeda
	reprodutor_2d.play()

func _ao_tomar_dano() -> void:
	vida_atual = clamp(vida_atual - 20.0, 0.0, vida_maxima)
	reprodutor_2d.stream = som_dano
	reprodutor_2d.play()
	vida_alterada.emit(vida_atual, vida_maxima)

func _ao_curar() -> void:
	vida_atual = clamp(vida_atual + 25.0, 0.0, vida_maxima)
	reprodutor_2d.stream = som_moeda
	reprodutor_2d.play()
	vida_alterada.emit(vida_atual, vida_maxima)

func _ao_adicionar_pontos() -> void:
	pontos += 100
	reprodutor_2d.stream = som_moeda
	reprodutor_2d.play()
	pontos_alterados.emit(pontos)

func _ao_mudar_vida(atual: float, maxima: float) -> void:
	var porcentagem = (atual / maxima) * 100.0
	texto_vida.text = "%d / %d HP" % [int(atual), int(maxima)]
	barra_vida.value = porcentagem
	
	var transicao = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	transicao.tween_property(barra_fantasma, "value", porcentagem, 0.5)

func _ao_mudar_pontos(novos_pontos: int) -> void:
	texto_pontos.text = "PONTOS: %05d" % novos_pontos
	
	var transicao = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	texto_pontos.scale = Vector2(1.3, 1.3)
	texto_pontos.pivot_offset = texto_pontos.size / 2.0
	transicao.tween_property(texto_pontos, "scale", Vector2(1.0, 1.0), 0.3)
