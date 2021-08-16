tool
extends Spatial
const LOD_PLUGIN_ID = 0

export (bool) var toggle = false
export (bool) var track = false

export (float, 0.01, 100) var default_lod1
export (float, 0.01, 100) var default_lod2
export (float, 0.01, 100) var default_lod3

var chunk_web = {}
var web_built = false

func _process(_delta):
	if toggle:
		toggle = false
		web_built = false
		chunk_web = _build_chunk_web(self)
		web_built = true
	
	if web_built and track:
		for key in chunk_web.keys():
			var pos = get_node("../PlayerPosition").global_transform.origin
			var dist = (chunk_web[key].position - pos).length()
			
			chunk_web[key].meshes[0].visible = 0 < dist and dist < chunk_web[key].borders[0]
			chunk_web[key].meshes[1].visible = chunk_web[key].borders[0] < dist and dist < chunk_web[key].borders[1]
			chunk_web[key].meshes[2].visible = chunk_web[key].borders[1] < dist and dist < chunk_web[key].borders[2]

func _build_chunk_web( target ) -> Dictionary:
	#var c = 0
	
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
					"position" : child.global_transform.origin,
					"borders"  : [ border_1,  border_2,  border_3],
					"meshes"   : [ child,     mesh_1,    mesh_2 ],
					"children" : {} 
				}
				
				#if c == 5:
				#	break
				#c += 1
	
	return graph
