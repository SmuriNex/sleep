extends Area3D

const VELOCIDADE: float = 7.0
const DANO_POR_SEGUNDO: float = 15.0
const TEMPO_VIDA: float = 4.0

var dono: Node3D = null
var alvo_atual: Node3D = null
var tempo_ultimo_dano: float = 0.0

@onready var timer_vida: Timer = $TimerVida

func _ready() -> void:
	if timer_vida:
		timer_vida.wait_time = TEMPO_VIDA
		timer_vida.one_shot = true
		timer_vida.start()
		timer_vida.timeout.connect(queue_free)
	else:
		print("ERRO: no TimerVida nao encontrado na cena da sombra!")
		queue_free()

func _physics_process(delta: float) -> void:
	if alvo_atual == null or not is_instance_valid(alvo_atual):
		alvo_atual = _buscar_inimigo_mais_proximo()
		return

	var direcao: Vector3 = (alvo_atual.global_position - global_position).normalized()
	global_position += direcao * VELOCIDADE * delta

	if direcao.length() > 0.01:
		var target_angle: float = atan2(direcao.x, direcao.z)
		rotation.y = lerp_angle(rotation.y, target_angle + PI, 0.2)

	tempo_ultimo_dano += delta
	if tempo_ultimo_dano >= 0.5:
		tempo_ultimo_dano = 0.0
		_aplicar_dano_em_area()

func _buscar_inimigo_mais_proximo() -> Node3D:
	var inimigos: Array = get_tree().get_nodes_in_group("inimigo")
	var menor_distancia: float = 20.0
	var inimigo_proximo: Node3D = null

	for inimigo in inimigos:
		if not is_instance_valid(inimigo) or inimigo == dono:
			continue

		var alvo: Node3D = inimigo as Node3D
		if alvo == null:
			continue

		var distancia: float = global_position.distance_to(alvo.global_position)
		if distancia < menor_distancia:
			menor_distancia = distancia
			inimigo_proximo = alvo

	return inimigo_proximo

func _aplicar_dano_em_area() -> void:
	var areas: Array[Area3D] = get_overlapping_areas()
	for area in areas:
		if not area.is_in_group("inimigo"):
			continue

		var bicho: Node3D = null
		if area.has_method("receber_dano"):
			bicho = area
		elif area.get_parent() and area.get_parent().has_method("receber_dano"):
			bicho = area.get_parent() as Node3D

		if bicho == null or bicho == dono:
			continue

		bicho.receber_dano(DANO_POR_SEGUNDO * 0.5)
		if bicho.has_method("receber_empurrao"):
			var direcao_empurrao: Vector3 = (bicho.global_position - global_position).normalized()
			direcao_empurrao.y = 0.0
			bicho.receber_empurrao(direcao_empurrao)

func acao_interagir(jogador: Node) -> void:
	print("Boneco de Treino diz: 'Pare de me bater e va salvar o mundo!'")
