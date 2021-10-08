tool
extends Spatial
const LOD_PLUGIN_ID = 0

export (NodePath) var track_target = null 
export (bool) var build = false
export (bool) var track = false setget _set_track
export (bool) var fade = false

var default_lod_1 = 4
var default_lod_2 = 8
var default_lod_3 = 16 
export (float, 0.0, 1.0)var fade_in_delay = 0.5

var chunk_web = {}
var web_built = false

func _get( property : String ):
	match property:
		"default_lod/default_lod_1":
			return default_lod_1
		"default_lod/default_lod_2":
			return default_lod_2
		"default_lod/default_lod_3":
			return default_lod_3 
		_ :
			return null

func _set( property : String, value ) -> bool:
	match property:
		"default_lod/default_lod_1":
			default_lod_1 = float(value)
			return true
		"default_lod/default_lod_2":
			default_lod_2 = float(value)
			return true
		"default_lod/default_lod_3":
			default_lod_3 = float(value)
			return true
		_ :
			return false

func _get_property_list():
	var result = []
	result.push_back({
			"name": "default_lod/default_lod_1",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.01,100,0.01,or_greater"
	})
	result.push_back({
			"name": "default_lod/default_lod_2",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.01,100,0.01,or_greater"
	})
	result.push_back({
			"name": "default_lod/default_lod_3",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.01,100,0.01,or_greater"
	})
	return result

func _ready():
	property_list_changed_notify()
	if Engine.editor_hint:
		pass
	else:
		chunk_web = _build_chunk_web(self)
		web_built = true

func _process(_delta):
	if Engine.editor_hint:
		if build:
			build = false
			web_built = false
			chunk_web = _build_chunk_web(self)
			web_built = true
	
		if web_built and track:
			_scan_chunk(chunk_web)
	else:
		if web_built:
			_scan_chunk(chunk_web)

func _scan_chunk( dict : Dictionary) -> void:
		var pos : Vector3
		for key in dict.keys():
			if track_target:
				pos = get_node(track_target).global_transform.origin
			else:
				pos = get_viewport().get_camera().global_transform.origin
			
			var dist : float = (dict[key].position - pos).length()
			
			_toggle_chunk( dict[key].meshes[0],  0                    < dist and dist <= dict[key].borders[0])
			_toggle_chunk( dict[key].meshes[1],  dict[key].borders[0] < dist and dist <= dict[key].borders[1])
			_toggle_chunk( dict[key].meshes[2],  dict[key].borders[1] < dist and dist <= dict[key].borders[2])
			
			## It will process the children only if the chunk is LOD 1 for performance reasons
			if dict[key].has("children") and dict[key].meshes[0].visible:
				_scan_chunk(dict[key].children)

func _toggle_chunk( chunk, toggle ):
	if chunk.visible != toggle:
		chunk.visible = toggle
		chunk.set_process(toggle)
		chunk.set_physics_process(toggle)
		chunk.set_process_unhandled_input(toggle)
		chunk.set_process_input(toggle)
	
		### Disable collisions wherever possible
		for child in chunk.get_children():
			if child is PhysicsBody:
				for collision in child.get_children():
					if collision is CollisionShape:
						collision.set_deferred("disabled", not toggle)

func _build_chunk_web( target ) -> Dictionary:
	var graph = {}
	for child in target.get_children():
		if child.has_method("set_visible"):
			if child.name.ends_with("-lod1"):
				var instance = child.name.trim_suffix("-lod1")
				
				## Get all LOD Meshes
				var mesh_1 = null
				if target.has_node(instance + "-lod2"):
					mesh_1 = target.get_node(instance + "-lod2")
				
				var mesh_2 = null
				if target.has_node(instance + "-lod3"):
					mesh_2 = target.get_node(instance + "-lod3")
				
				var border_1 = default_lod_1
				var border_2 = default_lod_2
				var border_3 = default_lod_3
				
				if child.get("LOD_PLUGIN_ID") == 1:
					border_1 = child.get("default_lod/default_lod_1")
					border_2 = child.get("default_lod/default_lod_2")
					border_3 = child.get("default_lod/default_lod_3")
					
				
				graph[instance] = {
					"position"        : child.global_transform.origin,
					"init_visibility" : child.visible,
					"borders"         : [ border_1,  border_2,  border_3],
					"meshes"          : [ child,     mesh_1,    mesh_2 ],
					"children"        : _build_chunk_web(child)
				}
	
	return graph

func _set_track(val) -> void:
	track = val
	if not val:
		if web_built:
			_clean_up(chunk_web)

func _clean_up( dict : Dictionary ) -> void:
	for key in dict.keys():
		dict[key].meshes[0].visible = dict[key].init_visibility
		if dict[key].meshes[1]:
			dict[key].meshes[1].visible = false
		if dict[key].meshes[2]:
			dict[key].meshes[2].visible = false
		
		if dict[key].has("children"):
			_clean_up(dict[key].children)


"""
if fade:
				### LOD 1 TRANSPARENCY
				dict[key].meshes[0].visible = 0 < dist and dist < dict[key].borders[1]
				
				
				### LOD 2 TRANSPARENCY
				var tmp
				if dict[key].meshes[1]: 
					tmp =   clamp(
								1.0 - (dist                      - dict[key].borders[1])
									/ (lerp(dict[key].borders[0], dict[key].borders[1], fade_in_delay) - dict[key].borders[1]), 
								0.0, 1.0 )
							*    float(dist < dict[key].borders[2])
					dict[key].meshes[1].visible = tmp != 0
					dict[key].meshes[1].get("material/0").albedo_color.a = tmp
				
				### LOD 3 TRANSPARENCY
				if dict[key].meshes[2]
					tmp =   clamp(
								1.0 - (dist                      - dict[key].borders[2])
									/ (lerp(dict[key].borders[1], dict[key].borders[2], fade_in_delay) - dict[key].borders[2]), 
								0.0, 1.0 )
					dict[key].meshes[2].visible = tmp != 0
					dict[key].meshes[2].get("material/0").albedo_color.a = tmp
			
"""
