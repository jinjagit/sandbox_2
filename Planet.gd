extends Spatial

onready var StatsText = get_node("../Control/CanvasLayer/RichTextLabel")
onready var Btn = get_node("../Control/CanvasLayer/VBoxContainer/Button")
onready var MenuRes = get_node("../Control/CanvasLayer/VBoxContainer/MenuButton")
onready var BtnMode = get_node("../Control/CanvasLayer/VBoxContainer/ButtonMode")
onready var TestData = preload("res://TestData.gd").new()
onready var test_data = TestData.some_data()
onready var GenerateFaceMeshData = preload("res://GenerateDataForFaceWithMargin.gd").new()

var resolution := 32
var margin := 3
var bench : String = ''
var bench_time : float = 0.0
var update_stats = false
var update_stats_time = 0
var update_stats_delay = 1000
var mode: String = 'calculate'

var popup

func _init():
	VisualServer.set_debug_generate_wireframes(true)

func save(content):
	# This saves to res:// but is not visible in editor file browser until extension changed.
	var file = File.new()
	file.open("res://TestWrite.gd", File.WRITE)
	file.store_string(content)
	file.close()

func update_stats_display():
	update_stats_time = OS.get_ticks_msec()
	update_stats = true

func generate_sphere():
	var startTime = OS.get_ticks_msec()

	for child in get_children():
		var face := child as FaceWithHiddenMargin
		face.generate_mesh(resolution, margin)
		
	var endTime = OS.get_ticks_msec()
	bench_time = (endTime - startTime) / 1000.0

	# write_data()

	update_stats_display()

func write_data():
	var name = "FaceMesh" + str(resolution) + "m" + str(margin)

	var normals = {
		"x+1": Vector3(1.0, 0.0, 0.0),
		"x-1": Vector3(-1.0, 0.0, 0.0),
		"y+1": Vector3(0.0, 1.0, 0.0),
		"y-1": Vector3(0.0, -1.0, 0.0),
		"z+1": Vector3(0.0, 0.0, 1.0),
		"z-1": Vector3(0.0, 0.0, -1.0)
	}

	var data_str = ""

	for key in normals:
		var normal = normals[key]
		var raw_data = GenerateFaceMeshData.generate_data(resolution, margin, normal)

		var vert_ary = ""
		for vec in raw_data["vertex_array"]:
			vert_ary += "                Vector3" + str(vec) + ",\n"

		data_str += "        \"" + str(key) + "\":{\n" + "            \"vertex_array\":[\n" + vert_ary + "            ],\n"

		var norm_ary = ""
		for vec in raw_data["normal_array"]:
			norm_ary += "                Vector3" + str(vec) + ",\n"

		data_str += "            \"normal_array\":[\n" + norm_ary + "            ],\n"

		var uv_ary = ""
		for vec in raw_data["uv_array"]:
			uv_ary += "                Vector2" + str(vec) + ",\n"

		data_str += "            \"uv_array\":[\n" + uv_ary + "            ],\n"

		var index_ary = ""
		for vec in raw_data["index_array"]:
			index_ary += "                " + str(vec) + ",\n"

		data_str += "            \"index_array\":[\n" + index_ary + "            ],\n" + "        },\n"

	var content = "class_name " + str(name) + "\n\n" + "func data():\n" + "    var data = {\n" + data_str + "    }\n\n" + "    return data\n"

	var file = File.new()
	file.open(name + ".gd", File.WRITE)
	file.store_string(content)
	file.close()

func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_P):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1 ) % 4
		
	if event is InputEventKey and Input.is_key_pressed(KEY_U):
		StatsText.visible = not StatsText.visible
		Btn.visible = not Btn.visible
		BtnMode.visible = not BtnMode.visible
		MenuRes.visible = not MenuRes.visible
		
func _ready():
	# var test_dict = {"one": Vector3(0.1, 1.1, 2.1), "two": [1, 2]}
	# save(
	# 	"class_name TestWrite\n\n"
	# 	+ "func some_data():\n"
	# 	+ "    return " + str(test_dict)
	# 	)
	
	generate_sphere()

	popup = MenuRes.get_popup()
	popup.add_item("32")
	popup.add_item("64")
	popup.add_item("128")
	popup.add_item("256")

	popup.connect("id_pressed", self, "_on_item_pressed")

	# print("Data read from TestData.some_data() {v}".format({"v":str(TestData.some_data()["-1"]["b"])}))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_object_local(Vector3(0, 1, 0), delta/19)
	rotate_object_local(Vector3(1, 0, 0), delta/23)
	#rotate_object_local(Vector3(0, 0, 1), delta/27)
	
func _physics_process(_delta):
	if update_stats == true && update_stats_time > 1 && OS.get_ticks_msec() > update_stats_time + update_stats_delay:
		update_stats_text()
		update_stats = false

		if update_stats_delay == 1000:
			update_stats_delay = 100

func update_stats_text():
	bench = "time to render: %.3f" % bench_time
	var num_vertices = ((resolution * resolution) + (margin * (resolution - 1) * 4)) * 6
	var indices : float = Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME)

	StatsText.text = (
		"Mode: " + mode + "\n\n"
		+ "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS)) + "\n\n"
		+ "Memory static:  " + str(round(Performance.get_monitor(Performance.MEMORY_STATIC)/1024/1024)) + " MB\n"
		+ "Memory dynamic: " + str(round(Performance.get_monitor(Performance.MEMORY_DYNAMIC)/1024/1024)) + " MB\n"
		+ "Vertex memory:  " + str(round(Performance.get_monitor(Performance.RENDER_VERTEX_MEM_USED)/1024/1024)) + " MB\n"
		+ "Texture memory: " + str(round(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)/1024/1024)) + " MB\n\n"
		+ "Resolution:     " + str(resolution) + "\n"
		+ "Indices:        " + str(indices) + "\n"
		+ "Triangles:      " + str(indices / 6)  + "\n"
		+ "Mesh vertices:  " + str(num_vertices) + "\n\n"
		+ bench
	)
		
func _on_Button_pressed():
	set_process(not is_processing())

func _on_item_pressed(ID):
	resolution = int(popup.get_item_text(ID))
	print(resolution, " pressed (via Planet class)")

	generate_sphere()

func _on_ButtonMode_pressed():
	if mode == 'calculate':
		mode = 'read'
	else:
		mode = 'calculate'
	
	update_stats_display()
