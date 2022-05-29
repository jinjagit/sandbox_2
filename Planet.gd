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

export var resolution := 32
export var margin := 3

var face_normals = {		
	"up": Vector3(0.0, 1.0, 0.0),
	"down": Vector3(0.0, -1.0, 0.0),
	"left": Vector3(-1.0, 0.0, 0.0),
	"right": Vector3(1.0, 0.0, 0.0),
	"front": Vector3(0.0, 0.0, 1.0),
	"back": Vector3(0.0, 0.0, -1.0)
}

var face_meshes = {"up": null, "down": null, "left": null, "right": null, "front": null, "back": null}

export var planet_rot = {"x": 0.0, "y": 1.0, "z": 0.0}
export var planet_rotation = false

export var bench_time : float = 0.0
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
	if planet_rotation == true:
		rotate_object_local(Vector3(1, 0, 0), (delta/20) * planet_rot.x)
		rotate_object_local(Vector3(0, 1, 0), (delta/20) * planet_rot.y)
		rotate_object_local(Vector3(0, 0, 1), (delta/20) * planet_rot.z)

func _physics_process(_delta):
	if show_fps == true:
		FpsText.text = (
			"FPS: " + str(Performance.get_monitor(Performance.TIME_FPS)) + "\n\n"
		)

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

	Canvas.start_update_stats = true

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
	
func _on_BtnPlanetRot_pressed():
	planet_rotation = not planet_rotation
	Canvas.start_update_stats = true

func _on_item_pressed(ID):
	resolution = int(popup_mesh_res.get_item_text(ID))
	generate_sphere()

func _on_rot_x_pressed(ID):
	planet_rot.x = float(popup_planet_rot.x.get_item_text(ID))
	Canvas.start_update_stats = true

func _on_rot_y_pressed(ID):
	planet_rot.y = float(popup_planet_rot.y.get_item_text(ID))
	Canvas.start_update_stats = true

func _on_rot_z_pressed(ID):
	planet_rot.z = float(popup_planet_rot.z.get_item_text(ID))
	Canvas.start_update_stats = true

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
