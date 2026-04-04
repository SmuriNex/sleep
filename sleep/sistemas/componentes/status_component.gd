class_name StatusComponent
extends Node

signal on_dano_recebido(quantidade: float, pos_atacante: Vector3)
signal on_cura_recebida(quantidade: float)
signal on_morte()
signal on_level_up(novo_nivel: int)

@export_group("Vida")
@export var vida_maxima: float = 100.0
@export var vida_atual: float = 100.0
@export var tempo_invencibilidade: float = 0.0

@export_group("Progressao")
@export var nivel_atual: int = 1
@export var xp_atual: int = 0
@export var xp_prox_nivel: int = 100

var is_invencivel: bool = false
var is_dead: bool = false

var _timer_invencibilidade: Timer = null

func _ready() -> void:
	normalizar_valores()
	_garantir_timer_invencibilidade()

func normalizar_valores() -> void:
	vida_maxima = max(vida_maxima, 0.0)
	vida_atual = clamp(vida_atual, 0.0, vida_maxima)
	tempo_invencibilidade = max(tempo_invencibilidade, 0.0)
	nivel_atual = max(nivel_atual, 1)
	xp_atual = max(xp_atual, 0)
	xp_prox_nivel = max(xp_prox_nivel, 1)

	if vida_atual <= 0.0:
		is_dead = true
		is_invencivel = false

func receber_dano(quantidade: float, pos_atacante: Vector3 = Vector3.ZERO) -> bool:
	if quantidade <= 0.0 or is_dead or is_invencivel:
		return false

	vida_atual = clamp(vida_atual - quantidade, 0.0, vida_maxima)
	var morreu: bool = vida_atual <= 0.0

	if morreu:
		is_dead = true
		_encerrar_invencibilidade()
	else:
		_iniciar_invencibilidade()

	on_dano_recebido.emit(quantidade, pos_atacante)

	if morreu:
		on_morte.emit()

	return true

func curar(quantidade: float) -> bool:
	if is_dead or quantidade <= 0.0 or vida_atual >= vida_maxima:
		return false

	var vida_antes: float = vida_atual
	vida_atual = clamp(vida_atual + quantidade, 0.0, vida_maxima)
	on_cura_recebida.emit(vida_atual - vida_antes)
	return true

func ganhar_xp(quantidade: int) -> void:
	if quantidade <= 0 or is_dead:
		return

	xp_atual += quantidade

	while xp_atual >= xp_prox_nivel and xp_prox_nivel > 0:
		xp_atual -= xp_prox_nivel
		_subir_de_nivel()

func matar() -> bool:
	if is_dead:
		return false

	vida_atual = 0.0
	is_dead = true
	_encerrar_invencibilidade()
	on_morte.emit()
	return true

func _subir_de_nivel() -> void:
	nivel_atual += 1
	vida_atual = vida_maxima
	on_level_up.emit(nivel_atual)

func _iniciar_invencibilidade() -> void:
	if tempo_invencibilidade <= 0.0:
		_encerrar_invencibilidade()
		return

	_garantir_timer_invencibilidade()
	is_invencivel = true
	_timer_invencibilidade.start(tempo_invencibilidade)

func _encerrar_invencibilidade() -> void:
	is_invencivel = false

	if _timer_invencibilidade != null and is_instance_valid(_timer_invencibilidade):
		_timer_invencibilidade.stop()

func _garantir_timer_invencibilidade() -> void:
	if _timer_invencibilidade != null and is_instance_valid(_timer_invencibilidade):
		return

	_timer_invencibilidade = get_node_or_null("TimerInvencibilidade") as Timer
	if _timer_invencibilidade == null:
		_timer_invencibilidade = Timer.new()
		_timer_invencibilidade.name = "TimerInvencibilidade"
		_timer_invencibilidade.one_shot = true
		add_child(_timer_invencibilidade)

	if not _timer_invencibilidade.timeout.is_connected(Callable(self, "_encerrar_invencibilidade")):
		_timer_invencibilidade.timeout.connect(Callable(self, "_encerrar_invencibilidade"))
