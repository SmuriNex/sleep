extends Area3D

@export var valor_cura: float = 25.0
@export var velocidade_rotacao: float = 2.0

@onready var visual_node: Node3D = _obter_visual_node()

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if visual_node != null:
		visual_node.rotate_y(velocidade_rotacao * delta)

func _on_body_entered(body: Node) -> void:
	if not body.has_method("curar"):
		return

	var resultado_cura: Variant = body.call("curar", valor_cura)
	if resultado_cura is bool and resultado_cura:
		monitoring = false
		queue_free()

func _obter_visual_node() -> Node3D:
	for child in get_children():
		if child is Node3D and not (child is CollisionShape3D):
			return child as Node3D

	return self
