class_name ConstantsDollyEffectController
## A static class used to hold all 'Dolly Effect Controller' plugin constants

# The custom type name used by the plugin
const CUSTOM_TYPE_NAME: String = "DollyEffectController"

# Path to the dolly controller script
const PATH_SCRIPT_DOLLY_EFFECT_CONTROLLER: String = "res://addons/dolly-camera-controller/scripts/classes/DollyEffectController.gd"

# Path to the icon of the plugin
const PATH_ICON_DOLLY_ICON: String = "res://addons/dolly-camera-controller/assets/icons/DollyIcon.svg"

## The minimum distance between camera and subject that we consider to apply a dolly zoom effect
const VALUE_CAMERA_MINIMUM_DISTANCE: float = 0.00000001

## The lowest focal that can be used by the camera
const VALUE_CAMERA_MINIMUM_FOCAL: float = 0.00000001

## The minimum amount of the dolly effect
const VALUE_EFFECT_AMOUNT_MIN: float = 0.0

## The maximum amount of the dolly effect
const VALUE_EFFECT_AMOUNT_MAX: float = 1.0


## The lowest FOV value used by a camera node.[br](Used to avoid warning)
const VALUE_CAMERA_INSTANCE_MIN_FOV: float = 1.0

## The max FOV value used by a camera node.[br](Used to avoid warning)
const VALUE_CAMERA_INSTANCE_MAX_FOV: float = 179.0

## The lowest culling distance for the camera
const VALUE_CAMERA_CULLING_MIN: float = 0.0

## The minimum camera width allowed
const VALUE_CAMERA_WIDTH_MIN: float = 0.0

## The maximum culling distance for the camera
const VALUE_CAMERA_CULLING_MAX: float = 10.0

## The lowest distance used by the effect
const VALUE_DISTANCE_MIN: float = 0.0

## The minimum subject influence on the effect
const VALUE_SUBJECT_INFLUENCE_MIN: float = 0.0

## The maximum subject influence on the effect
const VALUE_SUBJECT_INFLUENCE_MAX: float = 1.0

## The default amount for the dolly effect
const DEFAULT_AMOUNT: float = 1.0

## The default FOV of the camera
const DEFAULT_FOV: float = 75.0

## The default near plane culling distance of the camera
const DEFAULT_CULLING_NEAR: float = 0.05

## Should the near culling plane move with the effect by default
const DEFAULT_MOVE_CULLING: bool = true

## The default width of the camera (or frame/screen)
const DEFAULT_CAMERA_WIDTH: float = 1.0

## The default start distance of the effect (meters)
const DEFAULT_START_DISTANCE: float = 1.0

## The default distance of the effect (meters)
const DEFAULT_DISTANCE: float = 1.0

## The default subject distance influence on the effect
const DEFAULT_SUBJECT_INFLUENCE: float = 0.0

## The display class name of the 'DollyEffectController'
const CLASS_NAME_DOLLY_EFFECT_CONTROLLER: String = "DollyEffectController"

## The error label used when no camera instance are given to the controller
const ERROR_LABEL_NO_INSTANCE : String = "[{0}] '{1}' : no camera were instance given."

## The error label used when no subject instance are given to the controller
const ERROR_LABEL_NO_SUBJECT : String = "[{0}] '{1}' : no subject instance were given to calculate distance."

## An empty string representation
const EMPTY_STRING: String = "" 
