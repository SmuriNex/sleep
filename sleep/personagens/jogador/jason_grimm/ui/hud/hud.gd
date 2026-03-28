extends CanvasLayer

const PIXELS_POR_PONTO_VIDA: float = 2.0
const PIXELS_POR_PONTO_MAGIA: float = 3.0
const PIXELS_POR_PONTO_XP: float = 2.2

@onready var barra_vida: ProgressBar = $Control/BarraVidaJason
@onready var barra_magia: ProgressBar = $Control/BarraMagiaJason
@onready var barra_xp: ProgressBar = get_node_or_null("ContainerXP/BarraXPJason") as ProgressBar
@onready var label_nivel: Label = get_node_or_null("ContainerXP/LabelNivelJason") as Label

func atualizar_vida(vida_atual: float, vida_maxima: float) -> void:
	_atualizar_barra(barra_vida, vida_atual, vida_maxima, PIXELS_POR_PONTO_VIDA)

func atualizar_magia(magia_atual: float, magia_maxima: float) -> void:
	_atualizar_barra(barra_magia, magia_atual, magia_maxima, PIXELS_POR_PONTO_MAGIA)

	if barra_magia != null:
		barra_magia.visible = magia_maxima > 0.0

func atualizar_xp(atual: int, maximo: int, nivel: int) -> void:
	var xp_maximo: int = max(maximo, 1)

	if barra_xp != null:
		_atualizar_barra(barra_xp, float(atual), float(xp_maximo), PIXELS_POR_PONTO_XP)

	if label_nivel != null:
		label_nivel.text = "NV. %d" % max(nivel, 1)

func _atualizar_barra(barra: ProgressBar, valor_atual: float, valor_maximo: float, pixels_por_ponto: float) -> void:
	if barra == null:
		return

	var maximo_seguro: float = max(valor_maximo, 1.0)
	var largura: float = max(maximo_seguro * pixels_por_ponto, 1.0)

	barra.custom_minimum_size.x = largura
	barra.size.x = largura
	barra.max_value = maximo_seguro
	barra.value = clamp(valor_atual, 0.0, maximo_seguro)
