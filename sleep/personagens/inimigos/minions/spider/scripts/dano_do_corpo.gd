extends Area3D

func receber_dano(quantidade: float) -> void:
	if owner and owner.has_method("receber_dano"):
		owner.call("receber_dano", quantidade)

func receber_empurrao(direcao: Vector3) -> void:
	if owner and owner.has_method("receber_empurrao"):
		owner.call("receber_empurrao", direcao)
