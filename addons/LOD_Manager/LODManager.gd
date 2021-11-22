tool
extends Spatial

const LOD_OBJECT = preload("res://addons/LOD_Manager/LODObject.gd")
export (bool) var group_levels_of_detail = false setget _group_levels_of_detail
export (bool) var enable = false setget _enable
export (bool) var show_only_lod_1 = false setget _show_lod_1
export (bool) var show_only_lod_2 = false setget _show_lod_2
export (bool) var show_only_lod_3 = false setget _show_lod_3

export (NodePath) var tracking_target = null setget _set_target
var target_node : Node = null
var PLAYER_POSITION := Vector3.ZERO

"""
HANDLE BUTTON PRESS FOR REOGANIZING MESHES
"""
func _reparent_node(node_to_reparent, new_parent):
	var old_parent = node_to_reparent.get_parent()
	old_parent.remove_child(node_to_reparent)
	new_parent.add_child(node_to_reparent)
	_set_owner_for_node_and_children(node_to_reparent, new_parent.get_owner())

func _set_owner_for_node_and_children(node, owner):
	node.set_owner(owner)
	for child_node in node.get_children():
		_set_owner_for_node_and_children(child_node, owner)

func _group_levels_of_detail(val):
	group_levels_of_detail = val
	if val:
		var current_node = find_node("*-lod1", false)
		var counter = 0
		
		while current_node:
			### CREATING THE KNOT
			var node = Spatial.new()
			node.name = current_node.name.trim_suffix("-lod1")
			self.add_child(node, true)
			node.set_owner(self)
			node.set_script(LOD_OBJECT)
			
			## take old node's position
			node.global_transform = current_node.global_transform
			
			### REORGANISING THE NODES
			_reparent_node(current_node, node)
			current_node.transform = Transform()
			
			var lod_node = find_node(node.name + "-lod2", false)
			if lod_node:
				_reparent_node(lod_node, node)
				lod_node.transform = Transform()
			
			lod_node = find_node(node.name + "-lod3", false)
			if lod_node:
				_reparent_node(lod_node, node)
				lod_node.transform = Transform()
			
			counter += 1
			current_node = find_node("*-lod1", false)
		
		print("LOD Manager created ", str(counter), " new knots.")

"""
SHOW ONLY ONE LEVEL OF DETAIL
"""
func _show_lod_1(val):
	#show_only_lod_1 = val
	if val == true:
		_start_scan(1)

func _show_lod_2(val):
	#show_only_lod_2 = val
	if val == true:
		_start_scan(2)

func _show_lod_3(val):
	#show_only_lod_3 = val
	if val == true:
		_start_scan(3)

"""
MANAGE ACTIVATION
"""
func _enable(val):
	enable = val
	set_process(enable)

func _set_target(val):
	if val:
		if get_node_or_null(val):
			#print("Node Exists")
			if get_node(val).get("global_transform") != null:
				#print("Node has a position")
				tracking_target = val
				target_node = get_node(val)
			else:
				tracking_target = null
				target_node = null
		else:
			tracking_target = null
			target_node = null

func _process(_delta):
	if target_node:
		PLAYER_POSITION = target_node.global_transform.origin
	else:
		PLAYER_POSITION = Vector3.ZERO
	
	_start_scan()

"""
RECURSIVELY TRAVERSE THE TREE ENABLING AND DISABLING NODES
"""
func _start_scan(lod_mask : int = 0):
	for child in self.get_children():
		if child is LOD_OBJECT:
			_scan_node_tree(child, lod_mask)

func _scan_node_tree( node : LOD_OBJECT, lod_mask : int = 0 ):
	var distance : float = (node.global_transform.origin - PLAYER_POSITION).length_squared()
	
	for child in node.get_children():
		if child is LOD_OBJECT:
			_scan_node_tree( child, lod_mask )
		else:
			if lod_mask == 0:
				if child.name.ends_with("-lod1") and distance < node.lod_1 * node.lod_1 or\
				   child.name.ends_with("-lod2") and node.lod_1 * node.lod_1 <= distance and distance < node.lod_2 * node.lod_2 or \
				   child.name.ends_with("-lod3") and node.lod_2 * node.lod_2 <= distance and distance < node.lod_3 * node.lod_3:
					_tick_chunk(child, true)
					#prints(child.name, "- VISIBLE", distance)
				else:
					_tick_chunk(child, false)
					#prints(child.name, "- HIDDEN -", distance)
			else:
				if child.name.ends_with("-lod1") and lod_mask == 1 or\
				   child.name.ends_with("-lod2") and lod_mask == 2 or\
				   child.name.ends_with("-lod3") and lod_mask == 3:
					_tick_chunk(child, true)
				else:
					_tick_chunk(child, false)

"""
ENABLE/DISABLE NODES
"""
func _tick_chunk( chunk, toggle ):
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

#### DEBUG ####
#export (bool) var step = false setget _step
#func _step(val):
#	step = val
#	if step == true:
#		_start_scan()
