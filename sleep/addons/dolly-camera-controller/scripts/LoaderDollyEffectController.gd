@tool
class_name LoaderDollyEffectController
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type(
		ConstantsDollyEffectController.CUSTOM_TYPE_NAME,
		ConstantsDollyEffectController.CUSTOM_TYPE_NAME,
		preload(ConstantsDollyEffectController.PATH_SCRIPT_DOLLY_EFFECT_CONTROLLER),
		preload(ConstantsDollyEffectController.PATH_ICON_DOLLY_ICON))


func _exit_tree() -> void:
	remove_custom_type(ConstantsDollyEffectController.CUSTOM_TYPE_NAME)
