extends CharacterBody3D

enum ClimbState {
	NONE,
	HANGING,
	CLIMBING,
	RECOVERING,
}

const GROUP_BOX := "caixa"
const GROUP_ENEMY := "inimigo"
const GROUP_INTERACTABLE := "interagivel"

const INPUT_DEADZONE := 0.01
const MAX_HITBOX_RESULTS := 16

const ANIM_IDLE := &"jason_parado"
const ANIM_WALK := &"jason_andar"
const ANIM_PUSH := &"jason_empurrar"
const ANIM_DASH := &"jason_dash"
const ANIM_HANG := &"jason_pendurar"
const ANIM_CLIMB := &"jason_subir"
const ANIM_DROP := &"jason_soltar"
const ANIM_BLADE := &"jason_lamina"
const ANIM_SUMMON_SHADOWS := &"jason_invocar_sombras"
const ANIM_HIT := &"jason_tomardano"
const ANIM_DEATH := &"jason_morte"

const INVENCIBILITY_BLINK_INTERVAL := 0.08

const COMBO_ANIMATIONS := [
	&"jason_soco1",
	&"jason_chute2",
	&"jason_soco",
	&"jason_chute1",
]

const ACTION_ANIMATIONS := [
	&"jason_soco1",
	&"jason_chute2",
	&"jason_soco",
	&"jason_chute1",
	ANIM_SUMMON_SHADOWS,
	ANIM_CLIMB,
	ANIM_DROP,
	ANIM_HANG,
	ANIM_BLADE,
	ANIM_HIT,
	ANIM_DEATH,
]

const COMBO_BUFFER_CONDITIONS := [
	"vai_chute2",
	"vai_soco3",
	"vai_chute4",
]

@export_group("Atributos")
@export var vida_maxima: float = 100.0
@export var vida_atual: float = 100.0
@export var magia_maxima: float = 50.0
@export var magia_atual: float = 50.0

@export_group("Progressao")
@export var nivel_atual: int = 1
@export var xp_atual: int = 0
@export var xp_prox_nivel: int = 100

@export_group("Status de Defesa")
@export var knockback_force: float = 15.0
@export var tempo_invencibilidade: float = 1.2

@export_group("Movimento Base")
@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var action_brake_multiplier: float = 2.0
@export var model_turn_lerp: float = 0.15

@export_group("Dash")
@export var dash_speed: float = 20.0
@export var dash_duration: float = 0.25
@export var dash_ghost_delay: float = 0.10
@export var dash_cooldown: float = 0.80
@export var dash_ghost_scene: PackedScene = preload("res://personagens/jogador/jason_grimm/efeitos/dash/dash_ghost.tscn")

@export_group("Escalada")
@export var climb_drop_cooldown: float = 0.80
@export var climb_up_cooldown: float = 1.50
@export var climb_animation_time: float = 1.40
@export var climb_forward_distance: float = 1.50
@export var climb_up_height: float = 1.90
@export var climb_post_frames: int = 2
@export var climb_wall_offset: float = 0.30
@export var climb_unstuck_attempts: int = 15
@export var climb_unstuck_step: float = 0.05
@export var climb_test_margin: float = 0.001

@export_group("Camera")
@export var camera_sensitivity: float = 3.0
@export var camera_rotation_lerp: float = 0.15

@export_group("Combate")
@export var hand_damage: int = 10
@export var kick_damage: int = 20
@export var hitstop_duration: float = 0.08
@export var hitstop_time_scale: float = 0.05

@export_group("VFX e SFX")
@export var som_ataque_espada: AudioStream = preload("res://audio/sfx/combat/jason_atacando.wav")
@export var som_passos: AudioStream = preload("res://audio/sfx/combat/passos_jason.mp3")
@export var som_dano_recebido: AudioStream
@export var vfx_sangue_scene: PackedScene

@export_group("Mira e Interacao")
@export var target_radius: float = 4.0
@export var magic_target_radius: float = 20.0
@export var interaction_radius: float = 5.0
@export var melee_target_alignment: float = -0.2
@export var magic_target_alignment: float = -0.4

@export_group("Magias")
@export var blade_magic_cost: float = 10.0
@export var blade_spawn_distance: float = 1.5
@export var blade_cast_delay: float = 1.14
@export var shadow_army_magic_cost: float = 20.0
@export var shadow_army_count: int = 4
@export var shadow_army_radius: float = 2.0
@export var shadow_army_height: float = 0.2
@export var shadow_army_spawn_delay: float = 0.3
@export var habilidade_triangulo_scene: PackedScene = preload("res://personagens/jogador/jason_grimm/habilidades/esfera_sombria/esfera_sombria.tscn")
@export var entidade_sombra_scene: PackedScene = preload("res://personagens/jogador/jason_grimm/habilidades/sombra_viva/sombra_viva.tscn")

@export_group("Empurrar")
@export var push_impulse: float = 0.8
@export var push_grace_time: float = 0.15

@export_group("Hitboxes de Combate")
@export var area_mao_esq: Area3D
@export var shape_mao_esq: CollisionShape3D
@export var area_mao_dir: Area3D
@export var shape_mao_dir: CollisionShape3D
@export var area_perna_esq: Area3D
@export var shape_perna_esq: CollisionShape3D
@export var area_perna_dir: Area3D
@export var shape_perna_dir: CollisionShape3D

var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))

var is_dashing: bool = false
var is_invencivel: bool = false
var is_dead: bool = false
var dash_timer: float = 0.0
var ghost_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO

var is_acting: bool = false
var combo_step: int = 1
var animacao_anterior: StringName = &""
var inimigos_atingidos_neste_ataque: Array[Node] = []
var inimigo_alvo: Node3D = null

var climb_state: int = ClimbState.NONE
var cooldown_escalada: float = 0.0
var climb_timer: float = 0.0
var climb_recovery_frames: int = 0
var direcao_parede: Vector3 = Vector3.ZERO
var corpo_ignorado: PhysicsBody3D = null

var estava_empurrando: bool = false
var tempo_grace_empurrar: float = 0.0
var cam_rot_y: float = 0.0
var em_hitstop: bool = false
var death_collision_pending: bool = false
var invencibilidade_tween: Tween = null

@onready var corpo_shape: CollisionShape3D = $CollisionShape3D
@onready var hud = $HUD_Principal
@onready var anim_tree: AnimationTree = $jason/AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
@onready var model: Node3D = $jason
@onready var ray_parede: RayCast3D = $jason/RayCast_Parede
@onready var ray_borda: RayCast3D = $jason/RayCast_Borda
@onready var ponto_lamina: Marker3D = $PontosDeAtaque/Lamina
@onready var camera_pivot: SpringArm3D = $CameraPivot

func _ready() -> void:
	anim_tree.active = true
	vida_atual = clamp(vida_atual, 0.0, vida_maxima)
	magia_atual = clamp(magia_atual, 0.0, magia_maxima)
	nivel_atual = max(nivel_atual, 1)
	xp_atual = max(xp_atual, 0)
	xp_prox_nivel = max(xp_prox_nivel, 1)
	_atualizar_hud_vida()
	_atualizar_hud_magia()
	_atualizar_hud_xp()

	if camera_pivot:
		cam_rot_y = camera_pivot.rotation_degrees.y

	_definir_todas_hitboxes_ativas(false)

func _physics_process(delta: float) -> void:
	if is_dead:
		_processar_fisica_de_morte(delta)
		return

	_atualizar_cooldowns(delta)
	_atualizar_camera()

	if _processar_estado_escalada(delta):
		return

	_atualizar_estado_aereo(delta)
	var estado_atual: StringName = _atualizar_estado_de_acao()

	_processar_inputs_de_acao()
	var direction: Vector3 = _processar_movimento(delta)
	move_and_slide()

	var esta_empurrando: bool = _processar_empurrao(delta, direction)
	_atualizar_animacao_de_locomocao(estado_atual, direction, esta_empurrando)

func _processar_fisica_de_morte(delta: float) -> void:
	_definir_estado_de_locomocao(false, false)

	if not death_collision_pending:
		velocity = Vector3.ZERO
		_definir_estado_de_pulo(false)
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
		_definir_estado_de_pulo(true)
	else:
		velocity.y = 0.0
		_definir_estado_de_pulo(false)

	move_and_slide()
	_aplicar_desativacao_de_colisao_da_morte()

func _atualizar_cooldowns(delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer = max(dash_cooldown_timer - delta, 0.0)

	if cooldown_escalada > 0.0:
		cooldown_escalada = max(cooldown_escalada - delta, 0.0)

func _atualizar_camera() -> void:
	if is_dead or not camera_pivot:
		return

	if Input.is_action_just_pressed("voltarcamera"):
		cam_rot_y = model.rotation_degrees.y

	var giro_camera: float = Input.get_axis("cameraesquerda", "cameradireita")
	if abs(giro_camera) > INPUT_DEADZONE:
		cam_rot_y -= giro_camera * camera_sensitivity

	camera_pivot.rotation_degrees.y = lerp(camera_pivot.rotation_degrees.y, cam_rot_y, camera_rotation_lerp)

func _processar_estado_escalada(delta: float) -> bool:
	if climb_state == ClimbState.NONE:
		return false

	velocity = Vector3.ZERO

	match climb_state:
		ClimbState.HANGING:
			if Input.is_action_just_pressed("soltar"):
				_sair_da_escalada(ANIM_DROP, climb_drop_cooldown)
			elif Input.is_action_just_pressed("subir"):
				climb_state = ClimbState.CLIMBING
				climb_timer = climb_animation_time
				climb_recovery_frames = 0
				cooldown_escalada = climb_up_cooldown
				anim_state.start(ANIM_CLIMB)

			move_and_slide()

		ClimbState.CLIMBING:
			climb_timer -= delta
			if climb_timer <= 0.0:
				_executar_subida()

		ClimbState.RECOVERING:
			if climb_recovery_frames > 0:
				climb_recovery_frames -= 1
			else:
				_finalizar_escalada()

	return true

func _sair_da_escalada(animacao: StringName, cooldown: float) -> void:
	cooldown_escalada = cooldown
	_cancelar_escalada(true)
	anim_state.start(animacao)

func _executar_subida() -> void:
	global_position += Vector3(
		direcao_parede.x * climb_forward_distance,
		climb_up_height,
		direcao_parede.z * climb_forward_distance
	)

	_resolver_sobreposicao_pos_subida()
	anim_state.start(ANIM_IDLE)

	climb_recovery_frames = max(climb_post_frames, 0)
	climb_state = ClimbState.RECOVERING

func _resolver_sobreposicao_pos_subida() -> void:
	var tentativas: int = climb_unstuck_attempts
	while tentativas > 0 and test_move(global_transform, Vector3.ZERO, null, climb_test_margin, true):
		global_position += Vector3.UP * climb_unstuck_step
		tentativas -= 1

func _finalizar_escalada() -> void:
	_cancelar_escalada(true)

func _restaurar_colisao_de_escalada() -> void:
	corpo_shape.set_deferred("disabled", false)
	_liberar_corpo_ignorado_de_escalada()

func _cancelar_escalada(restaurar_colisao: bool) -> void:
	climb_state = ClimbState.NONE
	climb_timer = 0.0
	climb_recovery_frames = 0

	if restaurar_colisao:
		corpo_shape.set_deferred("disabled", false)

	_liberar_corpo_ignorado_de_escalada()

func _liberar_corpo_ignorado_de_escalada() -> void:
	if is_instance_valid(corpo_ignorado):
		remove_collision_exception_with(corpo_ignorado)
		if corpo_ignorado is RigidBody3D:
			corpo_ignorado.freeze = false

	corpo_ignorado = null

func _atualizar_estado_aereo(delta: float) -> void:
	if not is_on_floor() and not is_dashing:
		velocity.y -= gravity * delta
		_definir_estado_de_pulo(true)

		if velocity.y < 0.0 and cooldown_escalada <= 0.0:
			_tentar_agarrar_borda()
	elif is_on_floor() and not is_dashing:
		_definir_estado_de_pulo(false)

func _tentar_agarrar_borda() -> void:
	if not ray_parede.is_colliding() or not ray_borda.is_colliding():
		return

	var collider = ray_parede.get_collider()
	if collider == null or not collider.is_in_group(GROUP_BOX):
		return

	var corpo: PhysicsBody3D = collider as PhysicsBody3D
	if corpo == null:
		return

	climb_state = ClimbState.HANGING
	velocity = Vector3.ZERO
	corpo_ignorado = corpo
	add_collision_exception_with(corpo_ignorado)

	if corpo_ignorado is RigidBody3D:
		corpo_ignorado.freeze = true

	corpo_shape.set_deferred("disabled", true)

	var normal: Vector3 = ray_parede.get_collision_normal()
	model.rotation.y = atan2(normal.x, normal.z) + PI
	direcao_parede = -Vector3(normal.x, 0.0, normal.z).normalized()

	var ponto_colisao: Vector3 = ray_parede.get_collision_point()
	global_position.x = ponto_colisao.x + (normal.x * climb_wall_offset)
	global_position.z = ponto_colisao.z + (normal.z * climb_wall_offset)

	anim_state.start(ANIM_HANG)

func _atualizar_estado_de_acao() -> StringName:
	var estado_atual: StringName = anim_state.get_current_node()

	if estado_atual != animacao_anterior:
		inimigos_atingidos_neste_ataque.clear()
		animacao_anterior = estado_atual

	var estava_em_acao: bool = is_acting
	is_acting = ACTION_ANIMATIONS.has(estado_atual)

	if estava_em_acao and not is_acting:
		combo_step = 1
		inimigo_alvo = null
		_limpar_condicoes_combo()

	return estado_atual

func _processar_inputs_de_acao() -> void:
	if is_dead or _esta_em_animacao_de_stun():
		return

	if Input.is_action_just_pressed("dash") and _pode_iniciar_dash():
		start_dash()

	if Input.is_action_just_pressed("especial") and _tem_controle_total_no_solo():
		_usar_especial_lamina()

	if Input.is_action_just_pressed("ataque_leve") and is_on_floor() and not is_dashing:
		_buscar_inimigo_proximo()
		if is_acting:
			_handle_combo_buffer()
		else:
			anim_state.travel(COMBO_ANIMATIONS[0])
			combo_step = 1

	if Input.is_action_just_pressed("ataque_pesado") and _tem_controle_total_no_solo():
		if magia_atual >= shadow_army_magic_cost:
			anim_state.travel(ANIM_SUMMON_SHADOWS)

	if Input.is_action_just_pressed("interagir") and _tem_controle_total_no_solo():
		_tentar_interagir()

	if Input.is_action_just_pressed("pulo") and _tem_controle_total_no_solo():
		velocity.y = jump_velocity

func _pode_iniciar_dash() -> bool:
	return not is_dead and not is_acting and not is_dashing and dash_cooldown_timer <= 0.0

func _tem_controle_total_no_solo() -> bool:
	return is_on_floor() and not is_dead and not is_acting and not is_dashing

func _processar_movimento(delta: float) -> Vector3:
	if is_dashing:
		velocity = dash_direction * dash_speed
		dash_timer -= delta
		ghost_timer -= delta

		if ghost_timer <= 0.0:
			spawn_dash_ghost()
			ghost_timer = dash_ghost_delay

		if dash_timer <= 0.0:
			end_dash()

		return Vector3.ZERO

	if _esta_em_animacao_de_stun():
		_desacelerar_horizontal(move_speed * action_brake_multiplier)
		return Vector3.ZERO

	var direction: Vector3 = _obter_direcao_de_movimento()

	if is_acting:
		_desacelerar_horizontal(move_speed * action_brake_multiplier)
	elif direction == Vector3.ZERO:
		_desacelerar_horizontal(move_speed)
	else:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		_rotacionar_modelo_para(direction)

	return direction

func _obter_direcao_de_movimento() -> Vector3:
	var input_dir: Vector2 = Input.get_vector("esquerda", "direita", "frente", "traz")
	if input_dir.length() <= INPUT_DEADZONE:
		return Vector3.ZERO

	var base: Basis = camera_pivot.global_transform.basis if camera_pivot else transform.basis
	var direction: Vector3 = base * Vector3(input_dir.x, 0.0, input_dir.y)
	direction.y = 0.0
	return direction.normalized()

func _desacelerar_horizontal(valor: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, valor)
	velocity.z = move_toward(velocity.z, 0.0, valor)

func _rotacionar_modelo_para(direction: Vector3) -> void:
	var target_angle: float = atan2(direction.x, direction.z)
	model.rotation.y = lerp_angle(model.rotation.y, target_angle, model_turn_lerp)

func _esta_em_animacao_de_stun() -> bool:
	var estado_atual: StringName = anim_state.get_current_node()
	return estado_atual == ANIM_HIT or estado_atual == ANIM_DEATH

func _processar_empurrao(delta: float, direction: Vector3) -> bool:
	var empurrou_neste_frame: bool = false

	if _pode_empurrar(direction):
		empurrou_neste_frame = _aplicar_impulso_na_caixa()

	if empurrou_neste_frame:
		tempo_grace_empurrar = push_grace_time
	elif tempo_grace_empurrar > 0.0:
		tempo_grace_empurrar = max(tempo_grace_empurrar - delta, 0.0)

	var esta_empurrando: bool = (
		(empurrou_neste_frame or tempo_grace_empurrar > 0.0)
		and Input.is_action_pressed("agarrar")
		and direction != Vector3.ZERO
	)

	if not esta_empurrando:
		tempo_grace_empurrar = 0.0

	return esta_empurrando

func _pode_empurrar(direction: Vector3) -> bool:
	return (
		is_on_floor()
		and not is_dead
		and not is_acting
		and not is_dashing
		and direction != Vector3.ZERO
		and Input.is_action_pressed("agarrar")
	)

func _aplicar_impulso_na_caixa() -> bool:
	for i in range(get_slide_collision_count()):
		var colisao: KinematicCollision3D = get_slide_collision(i)
		var collider = colisao.get_collider()
		if collider is RigidBody3D and collider.is_in_group(GROUP_BOX):
			collider.apply_central_impulse(-colisao.get_normal() * push_impulse)
			return true

	return false

func _atualizar_animacao_de_locomocao(estado_atual: StringName, direction: Vector3, esta_empurrando: bool) -> void:
	if is_acting:
		_definir_estado_de_locomocao(false, true)
		return

	if is_dashing:
		return

	if esta_empurrando:
		_definir_estado_de_locomocao(false, false)
		if estado_atual != ANIM_PUSH:
			anim_state.travel(ANIM_PUSH)
		estava_empurrando = true
		return

	if direction == Vector3.ZERO:
		_definir_estado_de_locomocao(false, true)
		if estava_empurrando:
			anim_state.start(ANIM_IDLE)
			estava_empurrando = false
		return

	_definir_estado_de_locomocao(true, false)
	if estava_empurrando:
		anim_state.start(ANIM_WALK)
		estava_empurrando = false

func _definir_estado_de_pulo(esta_pulando: bool) -> void:
	anim_tree.set("parameters/conditions/is_jumping", esta_pulando)
	anim_tree.set("parameters/conditions/on_floor", not esta_pulando)

func _definir_estado_de_locomocao(esta_movendo: bool, esta_parado: bool) -> void:
	anim_tree.set("parameters/conditions/is_moving", esta_movendo)
	anim_tree.set("parameters/conditions/is_idle", esta_parado)

func _buscar_inimigo_proximo() -> void:
	if inimigo_alvo != null and is_instance_valid(inimigo_alvo):
		if global_position.distance_to(inimigo_alvo.global_position) <= target_radius:
			return

	inimigo_alvo = _encontrar_melhor_inimigo(target_radius, melee_target_alignment)

func _buscar_inimigo_para_magia() -> void:
	var novo_alvo: Node3D = _encontrar_melhor_inimigo(magic_target_radius, magic_target_alignment)
	if novo_alvo != null:
		inimigo_alvo = novo_alvo

func _encontrar_melhor_inimigo(raio_maximo: float, alinhamento_minimo: float) -> Node3D:
	var melhor_inimigo: Node3D = null
	var menor_distancia: float = raio_maximo
	var minha_frente: Vector3 = -model.global_transform.basis.z.normalized()

	for inimigo in get_tree().get_nodes_in_group(GROUP_ENEMY):
		if not is_instance_valid(inimigo):
			continue

		var alvo: Node3D = inimigo as Node3D
		if alvo == null:
			continue

		var distancia: float = global_position.distance_to(alvo.global_position)
		if distancia >= menor_distancia:
			continue

		var direcao_inimigo: Vector3 = (alvo.global_position - global_position).normalized()
		if minha_frente.dot(direcao_inimigo) > alinhamento_minimo:
			menor_distancia = distancia
			melhor_inimigo = alvo

	return melhor_inimigo

func _tentar_interagir() -> void:
	var mais_proximo: Node3D = null
	var menor_distancia: float = interaction_radius

	for objeto in get_tree().get_nodes_in_group(GROUP_INTERACTABLE):
		if not is_instance_valid(objeto):
			continue

		var interagivel: Node3D = objeto as Node3D
		if interagivel == null:
			continue

		var distancia: float = global_position.distance_to(interagivel.global_position)
		if distancia < menor_distancia:
			menor_distancia = distancia
			mais_proximo = interagivel

	if mais_proximo == null:
		return

	var direcao_npc: Vector3 = (mais_proximo.global_position - global_position).normalized()
	model.rotation.y = atan2(direcao_npc.x, direcao_npc.z)

	if mais_proximo.has_method("acao_interagir"):
		mais_proximo.call("acao_interagir", self)

func start_dash() -> void:
	var direction: Vector3 = _obter_direcao_de_movimento()
	dash_direction = direction if direction != Vector3.ZERO else -model.global_transform.basis.z.normalized()
	is_dashing = true
	dash_timer = dash_duration
	ghost_timer = 0.0
	dash_cooldown_timer = dash_cooldown
	_definir_estado_de_locomocao(false, false)
	anim_state.travel(ANIM_DASH)

func end_dash() -> void:
	is_dashing = false

func _obter_no_de_spawn() -> Node:
	if not is_inside_tree():
		return null

	var scene_tree: SceneTree = get_tree()
	if scene_tree == null:
		return null

	if scene_tree.current_scene != null and scene_tree.current_scene.is_inside_tree():
		return scene_tree.current_scene

	return scene_tree.root

func _instanciar_node_3d_em_spawn(cena: PackedScene) -> Node3D:
	if cena == null:
		return null

	var no_de_spawn: Node = _obter_no_de_spawn()
	if no_de_spawn == null:
		return null

	var instancia: Node3D = cena.instantiate() as Node3D
	if instancia == null:
		return null

	no_de_spawn.add_child(instancia)
	return instancia

func _spawnar_vfx_na_posicao(cena: PackedScene, posicao: Vector3) -> void:
	var vfx: Node3D = _instanciar_node_3d_em_spawn(cena)
	if vfx == null:
		return

	vfx.global_position = posicao

func _tocar_som_3d(som: AudioStream, posicao: Vector3) -> void:
	if som == null:
		return

	var no_de_spawn: Node = _obter_no_de_spawn()
	if no_de_spawn == null:
		return

	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	no_de_spawn.add_child(player)
	player.stream = som
	player.global_position = posicao
	player.finished.connect(Callable(player, "queue_free"))
	player.play()

func tocar_som_ataque() -> void:
	var origem_som: Vector3 = global_position
	if ponto_lamina != null and is_instance_valid(ponto_lamina) and ponto_lamina.is_inside_tree():
		origem_som = ponto_lamina.global_position

	_tocar_som_3d(som_ataque_espada, origem_som)

func tocar_som_passos() -> void:
	_tocar_som_3d(som_passos, global_position)

func spawn_dash_ghost() -> void:
	if dash_ghost_scene == null or model == null or not is_instance_valid(model) or not model.is_inside_tree():
		return

	var ghost: Node3D = _instanciar_node_3d_em_spawn(dash_ghost_scene)
	if ghost == null:
		return

	ghost.global_transform = model.global_transform

func _usar_especial_lamina() -> void:
	if is_dead or magia_atual < blade_magic_cost:
		return

	magia_atual -= blade_magic_cost
	_atualizar_hud_magia()
	_buscar_inimigo_para_magia()
	anim_state.travel(ANIM_BLADE)
	await get_tree().create_timer(blade_cast_delay).timeout

	if is_dead or not is_inside_tree():
		return

	_atirar_magia()

func _atirar_magia() -> void:
	if habilidade_triangulo_scene == null or model == null or not is_instance_valid(model) or not model.is_inside_tree():
		return

	var origem_magia: Vector3 = global_position + (-model.global_transform.basis.z.normalized() * blade_spawn_distance)
	if ponto_lamina != null and is_instance_valid(ponto_lamina) and ponto_lamina.is_inside_tree():
		origem_magia = ponto_lamina.global_position

	var rotacao_magia_y: float = model.rotation.y + PI

	if inimigo_alvo != null and is_instance_valid(inimigo_alvo):
		var direcao_alvo: Vector3 = inimigo_alvo.global_position - origem_magia
		if direcao_alvo.length_squared() > 0.0:
			direcao_alvo = direcao_alvo.normalized()
			rotacao_magia_y = atan2(direcao_alvo.x, direcao_alvo.z) + PI

	var nova_magia: Node3D = _instanciar_node_3d_em_spawn(habilidade_triangulo_scene)
	if nova_magia == null:
		return

	nova_magia.global_position = origem_magia
	nova_magia.rotation.y = rotacao_magia_y

	nova_magia.dono = self

func _invocar_exercito_sombras() -> void:
	if is_dead or entidade_sombra_scene == null or shadow_army_count <= 0 or not is_inside_tree():
		return

	magia_atual -= shadow_army_magic_cost
	_atualizar_hud_magia()

	for i in range(shadow_army_count):
		if is_dead or not is_inside_tree():
			return

		var origem_invocacao: Vector3 = global_position
		var nova_sombra: Node3D = _instanciar_node_3d_em_spawn(entidade_sombra_scene)
		if nova_sombra == null:
			return

		var angulo: float = (i * TAU) / shadow_army_count
		var offset: Vector3 = Vector3(
			cos(angulo) * shadow_army_radius,
			shadow_army_height,
			sin(angulo) * shadow_army_radius
		)

		nova_sombra.global_position = origem_invocacao + offset
		nova_sombra.dono = self
		await get_tree().create_timer(shadow_army_spawn_delay).timeout

		if is_dead or not is_inside_tree():
			return

func _handle_combo_buffer() -> void:
	if combo_step <= 0 or combo_step > COMBO_BUFFER_CONDITIONS.size():
		return

	var condition_name: String = COMBO_BUFFER_CONDITIONS[combo_step - 1]
	anim_tree.set("parameters/conditions/" + condition_name, true)
	combo_step += 1

func _limpar_condicoes_combo() -> void:
	for condition_name in COMBO_BUFFER_CONDITIONS:
		anim_tree.set("parameters/conditions/" + condition_name, false)

func ligar_mao_esquerda() -> void:
	_ativar_hitbox(area_mao_esq, shape_mao_esq, hand_damage)

func desligar_mao_esquerda() -> void:
	_desativar_hitbox(shape_mao_esq)

func ligar_mao_direita() -> void:
	_ativar_hitbox(area_mao_dir, shape_mao_dir, hand_damage)

func desligar_mao_direita() -> void:
	_desativar_hitbox(shape_mao_dir)

func ligar_perna_esquerda() -> void:
	_ativar_hitbox(area_perna_esq, shape_perna_esq, kick_damage)

func desligar_perna_esquerda() -> void:
	_desativar_hitbox(shape_perna_esq)

func ligar_perna_direita() -> void:
	_ativar_hitbox(area_perna_dir, shape_perna_dir, kick_damage)

func desligar_perna_direita() -> void:
	_desativar_hitbox(shape_perna_dir)

func _definir_todas_hitboxes_ativas(ativas: bool) -> void:
	_definir_hitbox_ativa(shape_mao_esq, ativas)
	_definir_hitbox_ativa(shape_mao_dir, ativas)
	_definir_hitbox_ativa(shape_perna_esq, ativas)
	_definir_hitbox_ativa(shape_perna_dir, ativas)

func _definir_hitbox_ativa(shape_node: CollisionShape3D, ativa: bool) -> void:
	if shape_node:
		shape_node.disabled = not ativa

func _ativar_hitbox(area_hitbox: Area3D, shape_node: CollisionShape3D, dano_base: int) -> void:
	if shape_node == null or area_hitbox == null:
		return

	shape_node.set_deferred("disabled", false)
	_checar_overlaps_imediatos(shape_node, area_hitbox.collision_mask, dano_base)

func _desativar_hitbox(shape_node: CollisionShape3D) -> void:
	if shape_node:
		shape_node.set_deferred("disabled", true)

func _checar_overlaps_imediatos(shape_node: CollisionShape3D, mask: int, dano_base: int) -> void:
	if shape_node == null or shape_node.shape == null:
		return

	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = shape_node.shape
	query.transform = shape_node.global_transform
	query.collision_mask = mask
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.exclude = [get_rid()]

	var resultados: Array = get_world_3d().direct_space_state.intersect_shape(query, MAX_HITBOX_RESULTS)
	for resultado in resultados:
		var collider = resultado["collider"]
		if collider is Area3D:
			_processar_dano(collider, dano_base)

func _on_hitbox_mao_esquerda_area_entered(area: Area3D) -> void:
	_processar_dano(area, hand_damage)

func _on_hitbox_mao_direita_area_entered(area: Area3D) -> void:
	_processar_dano(area, hand_damage)

func _on_hitbox_perna_esquerda_area_entered(area: Area3D) -> void:
	_processar_dano(area, kick_damage)

func _on_hitbox_perna_direita_area_entered(area: Area3D) -> void:
	_processar_dano(area, kick_damage)

func _processar_dano(area_do_inimigo: Area3D, valor_dano_base: int) -> void:
	if is_dashing or not is_acting:
		return

	if not area_do_inimigo.is_in_group(GROUP_ENEMY):
		return

	var alvo_do_dano: Node = area_do_inimigo if area_do_inimigo.has_method("receber_dano") else area_do_inimigo.get_parent()
	if alvo_do_dano == null or inimigos_atingidos_neste_ataque.has(alvo_do_dano):
		return

	if not alvo_do_dano.has_method("receber_dano"):
		return

	inimigos_atingidos_neste_ataque.append(alvo_do_dano)
	alvo_do_dano.call("receber_dano", valor_dano_base)
	_aplicar_hitstop(hitstop_duration)

func receber_dano(quantidade: float, atacante_pos: Vector3 = Vector3.ZERO) -> void:
	if is_dead or is_invencivel or is_dashing:
		return

	_spawnar_vfx_na_posicao(vfx_sangue_scene, global_position)
	_tocar_som_3d(som_dano_recebido, global_position)

	vida_atual = clamp(vida_atual - quantidade, 0.0, vida_maxima)
	_atualizar_hud_vida()

	if vida_atual <= 0.0:
		_morrer()
		return

	_preparar_reacao_de_dano()
	_aplicar_knockback(atacante_pos)
	anim_state.start(ANIM_HIT)
	_iniciar_invencibilidade()

func _preparar_reacao_de_dano() -> void:
	if climb_state != ClimbState.NONE:
		cooldown_escalada = max(cooldown_escalada, climb_drop_cooldown)
		_cancelar_escalada(true)

	_interromper_acao_atual()
	_definir_estado_de_locomocao(false, false)
	is_acting = true

func _interromper_acao_atual() -> void:
	is_dashing = false
	dash_timer = 0.0
	ghost_timer = 0.0
	dash_direction = Vector3.ZERO
	combo_step = 1
	inimigo_alvo = null
	inimigos_atingidos_neste_ataque.clear()
	_limpar_condicoes_combo()
	_definir_todas_hitboxes_ativas(false)

func _aplicar_knockback(atacante_pos: Vector3) -> void:
	var direcao_knockback: Vector3 = _calcular_direcao_knockback(atacante_pos)
	var impulso_knockback: Vector3 = direcao_knockback * knockback_force
	velocity.x = impulso_knockback.x
	velocity.z = impulso_knockback.z

func _calcular_direcao_knockback(atacante_pos: Vector3) -> Vector3:
	var direcao_knockback: Vector3 = global_position - atacante_pos
	direcao_knockback.y = 0.0

	if direcao_knockback.length_squared() <= INPUT_DEADZONE * INPUT_DEADZONE:
		direcao_knockback = -model.global_transform.basis.z
		direcao_knockback.y = 0.0

	return direcao_knockback.normalized()

func _iniciar_invencibilidade() -> void:
	is_invencivel = true
	_parar_piscar_modelo()

	if tempo_invencibilidade <= 0.0:
		_encerrar_invencibilidade()
		return

	var quantidade_piscadas: int = max(int(ceil(tempo_invencibilidade / INVENCIBILITY_BLINK_INTERVAL)), 1)
	var intervalo_piscada: float = tempo_invencibilidade / quantidade_piscadas

	invencibilidade_tween = create_tween()
	for _indice in range(quantidade_piscadas):
		invencibilidade_tween.tween_callback(Callable(self, "_alternar_visibilidade_modelo"))
		invencibilidade_tween.tween_interval(intervalo_piscada)

	invencibilidade_tween.finished.connect(Callable(self, "_encerrar_invencibilidade"))

func _alternar_visibilidade_modelo() -> void:
	if model:
		model.visible = not model.visible

func _encerrar_invencibilidade() -> void:
	is_invencivel = false
	invencibilidade_tween = null

	if model:
		model.visible = true

func _parar_piscar_modelo() -> void:
	if invencibilidade_tween != null:
		invencibilidade_tween.kill()
		invencibilidade_tween = null

	if model:
		model.visible = true

func _morrer() -> void:
	is_dead = true
	is_invencivel = false
	velocity = Vector3.ZERO
	_preparar_reacao_de_dano()
	_parar_piscar_modelo()
	death_collision_pending = true
	_aplicar_desativacao_de_colisao_da_morte()
	anim_state.start(ANIM_DEATH)

func _aplicar_desativacao_de_colisao_da_morte() -> void:
	if not death_collision_pending or corpo_shape == null:
		return

	if is_on_floor():
		corpo_shape.set_deferred("disabled", true)
		death_collision_pending = false

func _atualizar_hud_vida() -> void:
	if hud:
		hud.atualizar_vida(vida_atual, vida_maxima)

func _atualizar_hud_magia() -> void:
	if hud:
		hud.atualizar_magia(magia_atual, magia_maxima)

func curar(quantidade: float) -> bool:
	if is_dead or quantidade <= 0.0 or vida_atual >= vida_maxima:
		return false

	vida_atual = clamp(vida_atual + quantidade, 0.0, vida_maxima)
	_atualizar_hud_vida()
	return true

func _atualizar_hud_xp() -> void:
	if hud:
		hud.atualizar_xp(xp_atual, xp_prox_nivel, nivel_atual)

func ganhar_xp(quantidade: int) -> void:
	if quantidade <= 0:
		return

	xp_atual += quantidade

	while xp_atual >= xp_prox_nivel and xp_prox_nivel > 0:
		xp_atual -= xp_prox_nivel
		_subir_de_nivel()

	_atualizar_hud_xp()

func _subir_de_nivel() -> void:
	nivel_atual += 1
	vida_atual = vida_maxima
	magia_atual = magia_maxima
	_atualizar_hud_vida()
	_atualizar_hud_magia()

func _aplicar_hitstop(tempo_real_pausa: float) -> void:
	if em_hitstop:
		return

	em_hitstop = true
	Engine.time_scale = hitstop_time_scale
	await get_tree().create_timer(tempo_real_pausa, true, false, true).timeout
	Engine.time_scale = 1.0
	em_hitstop = false
