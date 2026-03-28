extends Area3D

@export var velocidade: float = 15.0
@export var dano: int = 25
@export var tempo_de_vida: float = 3.0

var dono: Node3D = null

func _ready() -> void:
	await get_tree().create_timer(tempo_de_vida).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_transform.origin += -global_transform.basis.z.normalized() * velocidade * delta

func _on_body_entered(body: Node) -> void:
	if body == dono:
		return

	if body.has_method("receber_dano"):
		body.receber_dano(dano)

func _on_area_entered(area: Area3D) -> void:
	if area == dono or area.get_parent() == dono:
		return

	if area.has_method("receber_dano"):
		area.receber_dano(dano)
	elif area.get_parent() and area.get_parent().has_method("receber_dano"):
		area.get_parent().receber_dano(dano)
