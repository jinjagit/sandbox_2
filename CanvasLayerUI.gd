extends CanvasLayer
class_name CanvasLayerUI

onready var StatsText = get_node("RichTextLabel")
onready var Planet = get_node("../../Planet")
onready var Camera = get_node("../../CameraPivot")

var update_stats = false
var start_update_stats = false
var update_stats_time = 0
var update_stats_delay = 1000

# Called when the node enters the scene tree for the first time.
# func _ready():
# 	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(_delta):
# 	pass

func _physics_process(_delta):
	if start_update_stats == true:
		update_stats_display()
		start_update_stats = false
		
	if update_stats == true && update_stats_time > 1 && OS.get_ticks_msec() > update_stats_time + update_stats_delay:
		update_stats_text()
		update_stats = false

		if update_stats_delay == 1000:
			update_stats_delay = 100

func update_stats_display():
	update_stats_time = OS.get_ticks_msec()
	update_stats = true

func update_stats_text():
	var resolution = Planet.resolution
	var margin = Planet.margin
	var bench_time = Planet.bench_time
	var planet_rot = Planet.planet_rot
	var planet_rotation = Planet.planet_rotation
	if planet_rotation == false:
		planet_rotation = "OFF"
	else:
		planet_rotation = "ON"
	var camera_rot = Camera.camera_rot
	var camera_rotation = Camera.camera_rotation
	if camera_rotation == false:
		camera_rotation = "OFF"
	else:
		camera_rotation = "ON"
	var bench = "time to render:  %.3f" % bench_time
	var num_vertices = ((resolution * resolution) + (margin * (resolution - 1) * 4)) * 6
	var indices : float = Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME)

	StatsText.text = (
		"Planet rotation: " + str(planet_rotation) + "\n"
		+ "x: " + str(planet_rot.x) + " y: " + str(planet_rot.y) + " z: " + str(planet_rot.z) + "\n\n"
		+ "Camera rotation: " + str(camera_rotation) + "\n"
		+ "x: " + str(camera_rot.x) + " y: " + str(camera_rot.y) + " z: " + str(camera_rot.z) + "\n\n"
		+ "Memory static:   " + str(round(Performance.get_monitor(Performance.MEMORY_STATIC)/1024/1024)) + " MB\n"
		+ "Memory dynamic:  " + str(round(Performance.get_monitor(Performance.MEMORY_DYNAMIC)/1024/1024)) + " MB\n"
		+ "Vertex memory:   " + str(round(Performance.get_monitor(Performance.RENDER_VERTEX_MEM_USED)/1024/1024)) + " MB\n"
		+ "Texture memory:  " + str(round(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)/1024/1024)) + " MB\n\n"
		+ "Mesh resolution: " + str(resolution) + "\n"
		+ "Indices:         " + str(indices) + "\n"
		+ "Triangles:       " + str(indices / 6)  + "\n"
		+ "Mesh vertices:   " + str(num_vertices) + "\n\n"
		+ bench
	)
