extends CharacterBody3D

const GROUP_PLAYER := "jogador"
const ATRITO_KNOCKBACK: float = 0.8
const MAX_HITBOX_RESULTS: int = 16
const DROP_VIDA_OFFSET: Vector3 = Vector3(0.0, 0.6, 0.0)
const DROP_VIDA_SCENE: PackedScene = preload("res://objetos_interativos/coletaveis/recuperar_vida.tscn")

@export_group("Atributos")
@export var vida_maxima: float = 75.0
@export var velocidade_andar: float = 3.0

@export_group("Combate")
@export var dano_ataque: float = 15.0
@export var alcance_ataque: float = 1.0
@export var alcance_perseguicao: float = 15.0
@export var tempo_recarga_ataque_base: float = 2.5
@export var tempo_tonteada_ao_receber_dano: float = 1.0
@export var tempo_recarga_apos_levar_dano: float = 1.5
@export_flags_3d_physics var mascara_colisao_jogador: int = 1

@export_group("VFX e SFX")
@export var som_patada: AudioStream = preload("res://audio/sfx/combat/aranha_atacando.wav")
@export var som_dano_recebido: AudioStream = preload("res://audio/sfx/combat/aranha.wav")
@export var som_morte: AudioStream = preload("res://audio/sfx/combat/aranha_morrendo.wav")
@export var som_passos_aranha: AudioStream = preload("res://audio/sfx/combat/aranha.wav")
@export var vfx_impacto_scene: PackedScene

@export_group("Progressao")
@export var xp_drop: int = 25

var vida_atual: float = 75.0
var esta_morto: bool = false
var tempo_tonteada: float = 0.0
var tempo_recarga_ataque: float = 0.0
var gravidade: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var knockback_velocity: Vector3 = Vector3.ZERO
var ataque_esquerdo_ativo: bool = false
var ataque_direito_ativo: bool = false
var alvos_atingidos_ataque_esquerdo: Array[Node] = []
var alvos_atingidos_ataque_direito: Array[Node] = []
var alvo: Node3D = null

@onready var anim: AnimationPlayer = $Spider/AnimationPlayer
@onready var shape_ataque_esquerdo: CollisionShape3D = $Spider/SpiderArmature/Skeleton3D/Esquerda1/HitboxEsquerda1/CollisionShape3D
@onready var shape_ataque_direito: CollisionShape3D = $Spider/SpiderArmature/Skeleton3D/Direita1/HitboxDireita1/CollisionShape3D

func _ready() -> void:
	vida_atual = clamp(vida_atual, 0.0, vida_maxima)
	anim.play("aranha/parado")
	alvo = _buscar_jogador_principal()
	desligar_ataque_esquerdo()
	desligar_ataque_direito()

func _physics_process(delta: float) -> void:
	if esta_morto:
		return

	_atualizar_alvo()
	_atualizar_temporizadores(delta)

	if tempo_tonteada > 0.0:
		_processar_tonteada(delta)
		move_and_slide()
		return

	_processar_movimento(delta)
	move_and_slide()

func _atualizar_temporizadores(delta: float) -> void:
	if tempo_recarga_ataque > 0.0:
		tempo_recarga_ataque = max(tempo_recarga_ataque - delta, 0.0)

	if tempo_tonteada > 0.0:
		tempo_tonteada = max(tempo_tonteada - delta, 0.0)

func _atualizar_alvo() -> void:
	if alvo != null and is_instance_valid(alvo):
		return

	alvo = _buscar_jogador_principal()

func _buscar_jogador_principal() -> Node3D:
	return get_tree().get_first_node_in_group(GROUP_PLAYER) as Node3D

func _conceder_xp_ao_jogador() -> void:
	if xp_drop <= 0:
		return

	var jogador: Node = alvo
	if jogador == null or not is_instance_valid(jogador):
		jogador = _buscar_jogador_principal()

	if jogador != null and jogador.has_method("ganhar_xp"):
		jogador.call("ganhar_xp", xp_drop)

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
	_tocar_som_3d(som_patada, global_position)

func tocar_som_passos() -> void:
	_tocar_som_3d(som_passos_aranha, global_position)

func _spawnar_drop_de_vida() -> void:
	if DROP_VIDA_SCENE == null or not is_inside_tree():
		return

	var drop_de_vida: Node3D = _instanciar_node_3d_em_spawn(DROP_VIDA_SCENE)
	if drop_de_vida == null:
		return

	drop_de_vida.global_position = global_position + DROP_VIDA_OFFSET

func _processar_tonteada(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravidade * delta
	else:
		velocity.y = 0.0

	if knockback_velocity.length() > 0.1:
		velocity.x = knockback_velocity.x
		velocity.z = knockback_velocity.z
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, ATRITO_KNOCKBACK)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 1.0)
		velocity.z = move_toward(velocity.z, 0.0, 1.0)

func _processar_movimento(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravidade * delta
	else:
		velocity.y = 0.0

	if alvo == null or not is_instance_valid(alvo):
		_desacelerar_horizontal()
		_tocar_animacao_se_necessario("aranha/parado")
		return

	var distancia: float = global_position.distance_to(alvo.global_position)

	if distancia < alcance_ataque:
		velocity.x = 0.0
		velocity.z = 0.0

		if tempo_recarga_ataque <= 0.0:
			anim.play("aranha/ataque")
			tempo_recarga_ataque = tempo_recarga_ataque_base
		elif anim.current_animation != "aranha/ataque":
			anim.play("aranha/parado")
		return

	if distancia < alcance_perseguicao and anim.current_animation != "aranha/ataque":
		var direcao: Vector3 = global_position.direction_to(alvo.global_position)
		direcao.y = 0.0
		direcao = direcao.normalized()

		velocity.x = direcao.x * velocidade_andar
		velocity.z = direcao.z * velocidade_andar

		if direcao != Vector3.ZERO:
			look_at(global_position - direcao, Vector3.UP)

		anim.play("aranha/andar")
		return

	_desacelerar_horizontal()
	_tocar_animacao_se_necessario("aranha/parado")

func _desacelerar_horizontal() -> void:
	velocity.x = move_toward(velocity.x, 0.0, 1.0)
	velocity.z = move_toward(velocity.z, 0.0, 1.0)

func _tocar_animacao_se_necessario(nome_animacao: StringName) -> void:
	if anim.current_animation != nome_animacao:
		anim.play(nome_animacao)

func ligar_ataque_esquerdo() -> void:
	if ataque_esquerdo_ativo:
		return

	alvos_atingidos_ataque_esquerdo.clear()
	_definir_hitbox_ativa(shape_ataque_esquerdo, true)
	ataque_esquerdo_ativo = true
	_checar_overlaps_imediatos(shape_ataque_esquerdo, mascara_colisao_jogador, dano_ataque, alvos_atingidos_ataque_esquerdo)

func desligar_ataque_esquerdo() -> void:
	ataque_esquerdo_ativo = false
	alvos_atingidos_ataque_esquerdo.clear()
	_definir_hitbox_ativa(shape_ataque_esquerdo, false)

func ligar_ataque_direito() -> void:
	if ataque_direito_ativo:
		return

	alvos_atingidos_ataque_direito.clear()
	_definir_hitbox_ativa(shape_ataque_direito, true)
	ataque_direito_ativo = true
	_checar_overlaps_imediatos(shape_ataque_direito, mascara_colisao_jogador, dano_ataque, alvos_atingidos_ataque_direito)

func desligar_ataque_direito() -> void:
	ataque_direito_ativo = false
	alvos_atingidos_ataque_direito.clear()
	_definir_hitbox_ativa(shape_ataque_direito, false)

func _definir_hitbox_ativa(shape_node: CollisionShape3D, ativa: bool) -> void:
	if shape_node:
		shape_node.disabled = not ativa

func _checar_overlaps_imediatos(shape_node: CollisionShape3D, mask: int, valor_dano: float, alvos_atingidos: Array[Node]) -> bool:
	if shape_node == null or shape_node.shape == null or shape_node.disabled:
		return false

	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = shape_node.shape
	query.transform = shape_node.global_transform
	query.collision_mask = mask
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = [get_rid()]

	var resultados: Array = get_world_3d().direct_space_state.intersect_shape(query, MAX_HITBOX_RESULTS)
	var acertou: bool = false

	for resultado in resultados:
		var collider: Object = resultado["collider"]
		var jogador: Node = _resolver_jogador_alvo(collider)
		if jogador == null or alvos_atingidos.has(jogador):
			continue

		if not jogador.has_method("receber_dano"):
			continue

		alvos_atingidos.append(jogador)
		jogador.call("receber_dano", valor_dano, global_position)
		acertou = true

	return acertou

func _resolver_jogador_alvo(collider: Object) -> Node:
	if collider is Node and collider.is_in_group(GROUP_PLAYER):
		return collider

	return null

func receber_dano(quantidade: float) -> void:
	if esta_morto:
		return

	_spawnar_vfx_na_posicao(vfx_impacto_scene, global_position)
	_tocar_som_3d(som_dano_recebido, global_position)

	vida_atual -= quantidade
	print("[ARANHA] Tomei ", quantidade, " de dano! Vida restante: ", vida_atual)

	tempo_tonteada = tempo_tonteada_ao_receber_dano
	tempo_recarga_ataque = tempo_recarga_apos_levar_dano
	anim.play("aranha/parado")

	if vida_atual <= 0.0:
		morrer()

func receber_empurrao(direcao_do_soco: Vector3) -> void:
	if esta_morto:
		return

	knockback_velocity = direcao_do_soco * 10.0

func morrer() -> void:
	esta_morto = true
	desligar_ataque_esquerdo()
	desligar_ataque_direito()
	anim.play("aranha/morte")
	_conceder_xp_ao_jogador()
	_spawnar_drop_de_vida()

	await anim.animation_finished
	await get_tree().create_timer(3.0).timeout
	_tocar_som_3d(som_morte, global_position)
	queue_free()
