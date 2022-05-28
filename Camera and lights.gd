extends Spatial

onready var MenuCamRotX = get_node("../Control/CanvasLayer/VBoxLeft/HBoxCamRotations/MenuCamRotX")
onready var MenuCamRotY = get_node("../Control/CanvasLayer/VBoxLeft/HBoxCamRotations/MenuCamRotY")
onready var MenuCamRotZ = get_node("../Control/CanvasLayer/VBoxLeft/HBoxCamRotations/MenuCamRotZ")

var camera_rot = {"x": 0.0, "y": 1.0, "z": 0.0}
var popup_camera_rot = {"x": null, "y": null, "z": null}
var camera_rotation = false


# Called when the node enters the scene tree for the first time.
func _ready():
	popup_camera_rot.x = MenuCamRotX.get_popup()
	add_rotation_popup_items(popup_camera_rot.x)
	popup_camera_rot.x.connect("id_pressed", self, "_on_cam_rot_x_pressed")

	popup_camera_rot.y = MenuCamRotY.get_popup()
	add_rotation_popup_items(popup_camera_rot.y)
	popup_camera_rot.y.connect("id_pressed", self, "_on_cam_rot_y_pressed")

	popup_camera_rot.z = MenuCamRotZ.get_popup()
	add_rotation_popup_items(popup_camera_rot.z)
	popup_camera_rot.z.connect("id_pressed", self, "_on_cam_rot_z_pressed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if camera_rotation == true:
		rotate_object_local(Vector3(1, 0, 0), (delta/20) * camera_rot.x)
		rotate_object_local(Vector3(0, 1, 0), (delta/20) * camera_rot.y)
		rotate_object_local(Vector3(0, 0, 1), (delta/20) * camera_rot.z)

func add_rotation_popup_items(popup_var):
	popup_var.add_item("0.0")
	popup_var.add_item("0.5")
	popup_var.add_item("1.0")
	popup_var.add_item("2.0")
	popup_var.add_item("4.0")
	popup_var.add_item("8.0")

func _on_BtnCamRot_pressed():
	camera_rotation = not camera_rotation

func _on_cam_rot_x_pressed(ID):
	camera_rot.x = float(popup_camera_rot.x.get_item_text(ID))
	#update_stats_display()

func _on_cam_rot_y_pressed(ID):
	camera_rot.y = float(popup_camera_rot.y.get_item_text(ID))
	#update_stats_display()

func _on_cam_rot_z_pressed(ID):
	camera_rot.z = float(popup_camera_rot.z.get_item_text(ID))
	#update_stats_display()
