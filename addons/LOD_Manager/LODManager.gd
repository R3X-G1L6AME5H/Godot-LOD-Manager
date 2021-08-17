tool
extends Spatial
const LOD_PLUGIN_ID = 0

export (NodePath) var track_target = null 
export (bool) var build = false
export (bool) var track = false setget _set_track
export (bool) var fade = false

export (float, 0.01, 100) var default_lod1
export (float, 0.01, 100) var default_lod2
export (float, 0.01, 100) var default_lod3
export (float, 0.0, 1.0)  var fade_in_delay = 0.5

var chunk_web = {}
var web_built = false

func _process(_delta):
	if build:
		build = false
		web_built = false
		chunk_web = _build_chunk_web(self)
		web_built = true
	
	if web_built and track:
		_scan_chunk(chunk_web)

func _scan_chunk( dict : Dictionary) -> void:
		var pos : Vector3
		for key in dict.keys():
			
			if Engine.editor_hint:
				if not track_target:
					track = false
					return
				pos = get_node(track_target).global_transform.origin
			
			else:
				if track_target:
					pos = get_node(track_target).global_transform.origin
				else:
					pos = get_viewport().get_camera().global_transform.origin
			
			var dist : float = (dict[key].position - pos).length()
			
			
			if fade:
				### LOD 1 TRANSPARENCY
				dict[key].meshes[0].visible = 0 < dist and dist < dict[key].borders[1]
				
				
				### LOD 2 TRANSPARENCY
				var tmp
				if dict[key].meshes[1]: 
					tmp =   clamp(\
								1.0 - (dist                      - dict[key].borders[1])\
									/ (lerp(dict[key].borders[0], dict[key].borders[1], fade_in_delay) - dict[key].borders[1]), \
								0.0, 1.0 )\
							*    float(dist < dict[key].borders[2])
					dict[key].meshes[1].visible = tmp != 0
					dict[key].meshes[1].get("material/0").albedo_color.a = tmp
				
				### LOD 3 TRANSPARENCY
				if dict[key].meshes[2]:
					tmp =   clamp(\
								1.0 - (dist                      - dict[key].borders[2])\
									/ (lerp(dict[key].borders[1], dict[key].borders[2], fade_in_delay) - dict[key].borders[2]), \
								0.0, 1.0 )
					dict[key].meshes[2].visible = tmp != 0
					dict[key].meshes[2].get("material/0").albedo_color.a = tmp
			
			else:
				dict[key].meshes[0].visible = 0 < dist and dist < dict[key].borders[0]
				if dict[key].meshes[1]:
					dict[key].meshes[1].visible = dict[key].borders[0] < dist and dist < dict[key].borders[1]
				if dict[key].meshes[2]:
					dict[key].meshes[2].visible = dict[key].borders[1] < dist and dist < dict[key].borders[2]
			
			## It will process the children only if the chunk is LOD 1 for performance reasons
			if dict[key].has("children") and dict[key].meshes[0].visible:
				_scan_chunk(dict[key].children)

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
				
				var border_1 = default_lod1
				var border_2 = default_lod2
				var border_3 = default_lod3
				
				if child.get("LOD_PLUGIN_ID") == 1:
					border_1 = child.get("plugin_lod/lod_1")
					border_2 = child.get("plugin_lod/lod_2")
					border_3 = child.get("plugin_lod/lod_3")
					
				
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
