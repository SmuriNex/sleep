extends Area3D

# O @export permite que você mude o dano de cada golpe lá no Inspetor do Godot!
@export var dano_do_golpe = 10 

# Esta função vai rodar sozinha quando a mão bater em algo
func _on_area_entered(area):
	# 1. Pergunta: A área que eu bati tem a etiqueta "inimigo"?
	if area.is_in_group("inimigo"):
		
		# 2. Como o script de vida está no "Pai" da área (o BonecoTreino),
		# nós pegamos o pai e mandamos o dano pra ele!
		var corpo_do_inimigo = area.get_parent()
		
		if corpo_do_inimigo.has_method("receber_dano"):
			corpo_do_inimigo.receber_dano(dano_do_golpe)
