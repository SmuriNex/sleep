@icon("icon.svg")
@tool
class_name SpriteFramesProgressBar extends Range

## [SpriteFrames] for getting texture for progress.
@export var sprite_frames: SpriteFrames: set = set_sprite_frames
@export_group("Animations")
## Main progress animation
@export var main_animation: String: set = set_main_animation
## Progress animation, when [member allow_greater] enable and [member value] is greater than [member value]
@export var greater_animation: String: set = set_greater_animation
## Progress animation, when [member allow_lesser] enable and [member value] is lesser than [member value]
@export var lesser_animation: String: set = set_lesser_animation
@export_group("Offsets")
## Offset for [member main_animation]
@export var main_offset: Vector2: set = set_main_offset
## Offset for [member greater_animation]
@export var greater_offset: Vector2: set = set_greater_offset
## Offset for [member lesser_animation]
@export var lesser_offset: Vector2: set = set_lesser_offset

var current_texture: Texture2D

func _value_changed(new_value: float) -> void:
	queue_redraw()

func _get(property: StringName) -> Variant:
	var result: Variant
	
	match property:
		&"size": result = Vector2(current_texture.get_size()) if current_texture else Vector2.ZERO
	
	return result

func _get_minimum_size() -> Vector2:
	return Vector2(current_texture.get_size()) if current_texture else Vector2.ZERO

func _draw() -> void:
	if sprite_frames && main_animation:
		var frame: int
		var texture: Texture2D
		var offset: Vector2
		if value <= max_value && value >= min_value:
			frame = clampi(floor(sprite_frames.get_frame_count(main_animation) * ratio), 0, sprite_frames.get_frame_count(main_animation) - 1)
			texture = sprite_frames.get_frame_texture(main_animation, frame)
			offset = main_offset
		elif value > max_value && allow_greater:
			texture = sprite_frames.get_frame_texture(greater_animation, 0)
			offset = greater_offset
		elif value < min_value && allow_lesser:
			texture = sprite_frames.get_frame_texture(lesser_animation, 0)
			offset = lesser_offset
		
		current_texture = texture
		draw_texture(texture, offset)
		
		if !clip_contents:
			if size < texture.get_size():
				size = texture.get_size()
		

func _validate_property(property: Dictionary) -> void:
	if property.name in ["main_animation", "greater_animation", "lesser_animation"]:
		if !sprite_frames: property.usage = PROPERTY_USAGE_NONE
		else:
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = ",".join(sprite_frames.get_animation_names())

func set_sprite_frames(new: SpriteFrames):
	sprite_frames = new
	queue_redraw()
	if Engine.is_editor_hint(): notify_property_list_changed()

func set_main_animation(new: String): main_animation = new; queue_redraw()
func set_greater_animation(new: String): greater_animation = new; queue_redraw()
func set_lesser_animation(new: String): lesser_animation = new; queue_redraw()

func set_main_offset(new: Vector2): main_offset = new; queue_redraw()
func set_greater_offset(new: Vector2): greater_offset = new; queue_redraw()
func set_lesser_offset(new: Vector2): lesser_offset = new; queue_redraw()
