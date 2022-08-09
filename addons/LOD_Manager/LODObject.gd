tool
extends Spatial

"""
	Level-of-Detail Object 
		by Nemo Czanderlitch/Nino Čandrlić	
			@R3X-G1L       (godot assets store)
			R3X-G1L6AME5H  (github)

	A slave script to LOD Manager. This object holds the rules of rendering
	used by the Manager. Namely, distances of each layer.
"""


const LOD_PLUGIN_ID = 1

#### EDITOR VARIABLES
export (float) var lod_1 : float = 8
export (float) var lod_2 : float = 16
export (float) var lod_3 : float = 32
