extends Spatial

onready var Up = get_node("./Up")
onready var Down = get_node("./Down")
onready var Left = get_node("./Left")
onready var Right = get_node("./Right")
onready var Front = get_node("./Front")
onready var Back = get_node("./Back")

onready var FpsText = get_node("../Control/CanvasLayerFPS/RichTextLabelFPS")
onready var StatsText = get_node("../Control/CanvasLayer/RichTextLabel")
onready var Canvas = get_node("../Control/CanvasLayer")
onready var MenuRes = get_node("../Control/CanvasLayer/VBoxLeft/MenuMeshRes")
onready var MenuRotX = get_node("../Control/CanvasLayer/VBoxLeft/HBoxAxesRotations/MenuRotX")
onready var MenuRotY = get_node("../Control/CanvasLayer/VBoxLeft/HBoxAxesRotations/MenuRotY")
onready var MenuRotZ = get_node("../Control/CanvasLayer/VBoxLeft/HBoxAxesRotations/MenuRotZ")

onready var GenerateFaceMeshData = preload("res://GenerateFaceMeshData.gd").new()

var resolution := 32
var margin := 3

var face_normals = {		
	"up": Vector3(0.0, 1.0, 0.0),
	"down": Vector3(0.0, -1.0, 0.0),
	"left": Vector3(-1.0, 0.0, 0.0),
	"right": Vector3(1.0, 0.0, 0.0),
	"front": Vector3(0.0, 0.0, 1.0),
	"back": Vector3(0.0, 0.0, -1.0)
}

var face_meshes = {"up": null, "down": null, "left": null, "right": null, "front": null, "back": null}

var planet_rot = {"x": 0.0, "y": 1.0, "z": 0.0}

var bench : String = ''
var bench_time : float = 0.0
var update_stats = false
var update_stats_time = 0
var update_stats_delay = 1000
var show_fps = true

var popup_mesh_res
var popup_planet_rot = {"x": null, "y": null, "z": null}

func _init():
	VisualServer.set_debug_generate_wireframes(true)
		
func _ready():	
	generate_sphere()

	popup_mesh_res = MenuRes.get_popup()
	popup_mesh_res.add_item("32")
	popup_mesh_res.add_item("64")
	popup_mesh_res.add_item("128")
	popup_mesh_res.add_item("256")
	popup_mesh_res.connect("id_pressed", self, "_on_item_pressed")

	popup_planet_rot.x = MenuRotX.get_popup()
	add_rotation_popup_items(popup_planet_rot.x)
	popup_planet_rot.x.connect("id_pressed", self, "_on_rot_x_pressed")

	popup_planet_rot.y = MenuRotY.get_popup()
	add_rotation_popup_items(popup_planet_rot.y)
	popup_planet_rot.y.connect("id_pressed", self, "_on_rot_y_pressed")

	popup_planet_rot.z = MenuRotZ.get_popup()
	add_rotation_popup_items(popup_planet_rot.z)
	popup_planet_rot.z.connect("id_pressed", self, "_on_rot_z_pressed")

func add_rotation_popup_items(popup_var):
	popup_var.add_item("0.0")
	popup_var.add_item("0.5")
	popup_var.add_item("1.0")
	popup_var.add_item("2.0")
	popup_var.add_item("4.0")
	popup_var.add_item("8.0")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_object_local(Vector3(1, 0, 0), (delta/20) * planet_rot.x)
	rotate_object_local(Vector3(0, 1, 0), (delta/20) * planet_rot.y)
	rotate_object_local(Vector3(0, 0, 1), (delta/20) * planet_rot.z)

func _physics_process(_delta):
	if show_fps == true:
		FpsText.text = (
			"FPS: " + str(Performance.get_monitor(Performance.TIME_FPS)) + "\n\n"
		)

	if update_stats == true && update_stats_time > 1 && OS.get_ticks_msec() > update_stats_time + update_stats_delay:
		update_stats_text()
		update_stats = false

		if update_stats_delay == 1000:
			update_stats_delay = 100

func generate_sphere():
	var startTime = OS.get_ticks_msec()

	for key in face_normals:
		var normal = face_normals[key]
		face_meshes[key] = GenerateFaceMeshData.generate_data(resolution, margin, normal)

	Up.render_mesh(face_meshes["up"])
	Down.render_mesh(face_meshes["down"])
	Left.render_mesh(face_meshes["left"])
	Right.render_mesh(face_meshes["right"])
	Front.render_mesh(face_meshes["front"])
	Back.render_mesh(face_meshes["back"])
		
	var endTime = OS.get_ticks_msec()
	bench_time = (endTime - startTime) / 1000.0

	update_stats_display()

func update_stats_display():
	update_stats_time = OS.get_ticks_msec()
	update_stats = true

func update_stats_text():
	bench = "time to render:  %.3f" % bench_time
	var num_vertices = ((resolution * resolution) + (margin * (resolution - 1) * 4)) * 6
	var indices : float = Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME)

	StatsText.text = (
		"Palent rotation:\n"
		+"x: " + str(planet_rot.x) + " y: " + str(planet_rot.y) + " z: " + str(planet_rot.z) + "\n\n"
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

# --------------- UI Actions ------------------------

func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_P):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1 ) % 4
		
	if event is InputEventKey and Input.is_key_pressed(KEY_U):
		for child in Canvas.get_children():
			child.visible = not child.visible

	if event is InputEventKey and Input.is_key_pressed(KEY_F):
		FpsText.visible = not FpsText.visible
		show_fps = not show_fps
	
func _on_Button_pressed():
	set_process(not is_processing())

func _on_item_pressed(ID):
	resolution = int(popup_mesh_res.get_item_text(ID))
	generate_sphere()

func _on_rot_x_pressed(ID):
	planet_rot.x = float(popup_planet_rot.x.get_item_text(ID))
	update_stats_display()

func _on_rot_y_pressed(ID):
	planet_rot.y = float(popup_planet_rot.y.get_item_text(ID))
	update_stats_display()

func _on_rot_z_pressed(ID):
	planet_rot.z = float(popup_planet_rot.z.get_item_text(ID))
	update_stats_display()

func _on_ButtonUp_pressed():
	Up.visible = not Up.visible
	
func _on_ButtonDown_pressed():
	Down.visible = not Down.visible
	
func _on_ButtonLeft_pressed():
	Left.visible = not Left.visible
	
func _on_ButtonRight_pressed():
	Right.visible = not Right.visible
	
func _on_ButtonFront_pressed():
	Front.visible = not Front.visible
	
func _on_ButtonBack_pressed():
	Back.visible = not Back.visible
