@tool
@icon("res://addons/dolly-camera-controller/assets/icons/DollyIcon.svg")
extends Node
class_name DollyEffectController
## A script used to make a DollyZoom effect.
## @experimental
## [br]
## Instantiate it and attach it to a camera.[br]
## The controller will adjust the camera FOV
## depending of the distance between the camera and the tacked
## subject or start distance.[br]
## [br]
## [b]Dolly Zoom Effect (Vertigo Effect)[/b]
## [br]
## The [b]Dolly Zoom[/b] is a camera technique where the
## camera moves closer or farther from a subject while
## zooming in or out to keep the subject the same size.
## This creates a disorienting effect where the background
## appears to expand or contract.
## [br]
## [b]How It Works:[/b] [br]
## - Moving [b]forward[/b] (dolly in) → Zoom [b]out[/b]. [br]
## - Moving [b]backward[/b] (dolly out) → Zoom [b]in[/b]. [br]
## [br]
## [b]Famous Examples:[/b] [br]
## - [i]Vertigo[/i] (1958) – First use of the effect. [br]
## - [i]Jaws[/i] (1975) – Iconic shark attack realization scene. [br]
## - [i]Goodfellas[/i] (1990) – Used to show paranoia. [br]
## [br]
## This effect is widely used in filmmaking to create tension and unease. [br]
## [br]
## Wikipedia article : [url]https://en.wikipedia.org/wiki/Dolly_zoom[/url] [br]



#region Exported Parameters
## Is the effect active
@export
var enabled: bool = true

## How much is the dolly effect applied
@export_range(
	ConstantsDollyEffectController.VALUE_EFFECT_AMOUNT_MIN,
	ConstantsDollyEffectController.VALUE_EFFECT_AMOUNT_MAX)
var amount: float = ConstantsDollyEffectController.DEFAULT_AMOUNT

@export_category("Camera")

## The camera instance where the dolly effect is applied
@export
var camera: Camera3D

## The base FOV used before dolly
@export_range(
	ConstantsDollyEffectController.VALUE_CAMERA_INSTANCE_MIN_FOV,
	ConstantsDollyEffectController.VALUE_CAMERA_INSTANCE_MAX_FOV)
var camera_fov: float = ConstantsDollyEffectController.DEFAULT_FOV

## The Camera distance for near culling
@export_range(
	ConstantsDollyEffectController.VALUE_CAMERA_CULLING_MIN,
	ConstantsDollyEffectController.VALUE_CAMERA_CULLING_MAX)
var camera_near: float = ConstantsDollyEffectController.DEFAULT_CULLING_NEAR

## Does the dolly effect move the near culling plane
@export
var move_near_culling: bool = ConstantsDollyEffectController.DEFAULT_MOVE_CULLING

## The width of the camera optic
@export
var camera_width: float = ConstantsDollyEffectController.DEFAULT_CAMERA_WIDTH : set=set_camera_width

@export_category("Subject")

@export_subgroup("Distance")

## The start distance to the where the dolly zoom start
@export
var start_distance: float = ConstantsDollyEffectController.DEFAULT_START_DISTANCE : set=set_start_distance

## The distance to the subject
@export
var distance: float = ConstantsDollyEffectController.DEFAULT_DISTANCE : set=set_distance

@export_subgroup("Subject Instance")

## How much does the distance to a subject (3D instance) influences the effect (0.0 : no, 1.0 : use instance)
@export_range(
	ConstantsDollyEffectController.VALUE_SUBJECT_INFLUENCE_MIN,
	ConstantsDollyEffectController.VALUE_SUBJECT_INFLUENCE_MAX)
var subject_influence: float = ConstantsDollyEffectController.DEFAULT_SUBJECT_INFLUENCE

## The subject instance used to calculate distance between camera and subject
@export
var subject: Node3D = null

## Offset between subject origin and the focused point
@export
var subject_offset: Vector3 = Vector3.ZERO

## An action used to set the start distance
## of the effect from the instance of a subject
@export_tool_button("Set start distance")
var action_set_distance = set_distance_from_subject
#endregion


#region Local Variables
# ...
#endregion



#region Static Functions
## A static function used to convert a FOV (deg) to focal (mm) [br]
## [br]
## [param fov] The FOV to convert [br]
## [param camera_width] The width of the camera optic [br]
## [br]
## return the focal value
static func fov_to_focal(fov: float, camera_width: float = 1.0) -> float:
	var f: float = deg_to_rad(fov)
	return (camera_width / 2.0) / tan(f / 2.0)


## A static function used to convert a focal (mm) to a FOV (deg) [br]
## [br]
## [param focal] The focal to convert [br]
## [param camera_width] The width of the camera optic [br]
## [br]
## return the FOV value
static func focal_to_fov(focal: float, camera_width: float = 1.0) -> float:
	return rad_to_deg(2.0 * atan((camera_width / 2.0) / max(focal, ConstantsDollyEffectController.VALUE_CAMERA_MINIMUM_FOCAL)))


## A function that calculate the FOV to make a dolly zoom effect [br]
## [br]
## [param start_fov] The FOV to that the effect started with [br]
## [param start_distance] The distance where the effect started [br]
## [param current_distance] How far the camera currently is [br]
## [param camera_width] The width of the camera optic [br]
## [br]
## return the FOV to apply to the camera
static func dollyzoom(start_fov: float, start_distance: float, current_distance: float, camera_width: float = 1.0) -> float:
	var start_focal: float = fov_to_focal(start_fov, camera_width)
	var start_size: float = start_focal / max(start_distance, ConstantsDollyEffectController.VALUE_CAMERA_MINIMUM_DISTANCE) # avoid 0 div
	var current_focal = start_size * current_distance
	return focal_to_fov(current_focal)
#endregion


#region Functions
func _ready() -> void:
	if not camera:
		push_warning(
			ConstantsDollyEffectController.ERROR_LABEL_NO_INSTANCE
			.format([ConstantsDollyEffectController.CLASS_NAME_DOLLY_EFFECT_CONTROLLER, name]))


func  _process(delta: float) -> void:
	_process_dolly()


## Apply the dolly effect to the camera instance [br]
func _process_dolly() -> void:
	# Do we apply the effect 
	if not enabled: return
	
	# if no camera instance to use abort
	if not camera: return
	
	# The distance that will be used to calculate dolly effect
	var dist: float = distance
	
	# Calculate the distance that we consider for the effect
	if subject and subject_influence > ConstantsDollyEffectController.VALUE_SUBJECT_INFLUENCE_MIN:
		var real_distance = camera.global_position.distance_to(subject.global_position + subject_offset)
		dist += (real_distance - distance) * subject_influence
	
	# Move culling near plane
	if move_near_culling:
		camera.near = max(camera_near + (dist - start_distance) * amount, camera_near)
	else:
		camera.near = camera_near
	
	# Do dolly logic here
	var new_fov = dollyzoom(camera_fov, start_distance, dist)
	new_fov = min(ConstantsDollyEffectController.VALUE_CAMERA_INSTANCE_MAX_FOV, max(ConstantsDollyEffectController.VALUE_CAMERA_INSTANCE_MIN_FOV, new_fov))
	camera.fov = camera_fov + (new_fov - camera_fov) * amount
#endregion



#region Getter & Setters
func set_distance_from_subject() -> void:
	if subject and camera:
		var d: float = camera.global_position.distance_to(subject.global_position)
		set_start_distance(d)


func set_distance(value: float) -> void:
	distance = max(value, ConstantsDollyEffectController.VALUE_DISTANCE_MIN)


func set_start_distance(value: float) -> void:
	start_distance = max(value, ConstantsDollyEffectController.VALUE_DISTANCE_MIN)


func set_camera_width(value: float) -> void:
	camera_width = max(value, ConstantsDollyEffectController.VALUE_CAMERA_WIDTH_MIN)


func set_subject_influence(value: float) -> void:
	subject_influence = clamp(value, ConstantsDollyEffectController.VALUE_SUBJECT_INFLUENCE_MIN, ConstantsDollyEffectController.VALUE_SUBJECT_INFLUENCE_MAX)
	if not subject and subject_influence > ConstantsDollyEffectController.VALUE_SUBJECT_INFLUENCE_MIN:
			push_warning(
				ConstantsDollyEffectController.ERROR_LABEL_NO_SUBJECT
				.format([ConstantsDollyEffectController.CLASS_NAME_DOLLY_EFFECT_CONTROLLER, name]))
#endregion



#region overrides
func _to_string() -> String:
	return """
	[{0}]
	- enabled: {1}
	- enabled: {2}
	--- Camera instance ---
	- Camera: '{3}'
	- camera_fov: {4}
	- camera_near: {5}
	- move_near_culling: {6}
	- camera_width: {7}
	- start_distance: {8}
	--- Subject ---
	- distance: {9}
	- subject_influence: {10}
	- subject: '{11}'
	- subject_offset: {12}
	""".format([
		ConstantsDollyEffectController.CLASS_NAME_DOLLY_EFFECT_CONTROLLER,
		enabled,
		amount,
		camera.name if camera != null else ConstantsDollyEffectController.EMPTY_STRING,
		camera_fov,
		camera_near,
		move_near_culling,
		camera_width,
		start_distance,
		distance,
		subject_influence,
		subject.name if subject != null else ConstantsDollyEffectController.EMPTY_STRING,
		subject_offset
	])

#endregion
