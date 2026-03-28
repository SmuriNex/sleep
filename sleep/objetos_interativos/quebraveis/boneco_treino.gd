extends StaticBody3D

var vida = 1000

func receber_dano(dano):
	vida -= dano
	print("POW! O boneco tomou ", dano, " de dano! Vida restante: ", vida)
	
	if vida <= 0:
		print("O boneco foi DESTRUÍDO!")
		queue_free()

# NOVA FUNÇÃO: Faz o boneco deslizar para trás!
func receber_empurrao(direcao_do_empurrao: Vector3):
	var forca_do_pulo = 2.5 # Quantos metros ele vai voar para trás. Aumente se quiser!
	var posicao_final = global_position + (direcao_do_empurrao * forca_do_pulo)
	
	# Cria uma animação suave via código (Tween)
	var tween = get_tree().create_tween()
	
	# Desliza a posição do boneco até a posição final em 0.2 segundos
	tween.tween_property(self, "global_position", posicao_final, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func acao_interagir(jogador):
	print("Boneco de Treino diz: 'Pode parar de me bater? Eu sou so de teste!'")
