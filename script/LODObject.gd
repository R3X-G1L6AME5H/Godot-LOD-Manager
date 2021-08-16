tool
extends Spatial
const LOD_PLUGIN_ID = 1

#### MANAGMENT VARIABLES
var neibourghs = []

#### EDITOR VARIABLES
var lod_1 : float = 8
var lod_2 : float = 16
var lod_3 : float = 32

var neibourgh_radius : float 

func _get( property : String ):
	match property:
		"plugin_lod/lod_1":
			return lod_1
		"plugin_lod/lod_2":
			return lod_2
		"plugin_lod/lod_3":
			return lod_3 
		_ :
			return null

func _set( property : String, value ) -> bool:
	match property:
		"plugin_lod/lod_1":
			lod_1 = float(value)
			return true
		"plugin_lod/lod_2":
			lod_2 = float(value)
			return true
		"plugin_lod/lod_3":
			lod_3 = float(value)
			return true
		_ :
			return false

func _get_property_list():
	var result = []
	result.push_back({
			"name": "plugin_lod/lod_1",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.01,100,0.01,or_greater"
	})
	result.push_back({
			"name": "plugin_lod/lod_2",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.01,100,0.01,or_greater"
	})
	result.push_back({
			"name": "plugin_lod/lod_3",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.01,100,0.01,or_greater"
	})
	return result

func _ready():
	property_list_changed_notify()
