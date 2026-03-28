extends Node3D

func _ready():
	print("👻 O FANTASMA NASCEU (Pintando tudo de Void-Black)!") 
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	_configurar_fantasma_void(self, tween)

	await get_tree().create_timer(0.4).timeout
	queue_free()

func _configurar_fantasma_void(node, tween):
	for filho in node.get_children():
		if filho is MeshInstance3D:
			# 👉 CORRIGIDO AQUI: Trocamos BaseMaterial3D.new() por StandardMaterial3D.new()!
			var void_mat = StandardMaterial3D.new()
			
			void_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			void_mat.albedo_color = Color(0, 0, 0) # Preto Puro (Void)
			void_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

			for i in range(filho.get_surface_override_material_count()):
				filho.set_surface_override_material(i, void_mat)
				
				# Anima a transparência (Alpha) para 0.0 em 0.4 segundos
				tween.tween_property(void_mat, "albedo_color:a", 0.0, 0.4)
		
		_configurar_fantasma_void(filho, tween)
