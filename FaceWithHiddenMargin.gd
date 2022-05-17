tool
extends MeshInstance
class_name FaceWithHiddenMargin

func render_mesh(mesh_data):
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)

	arrays[Mesh.ARRAY_VERTEX] = mesh_data.vertex_array
	arrays[Mesh.ARRAY_NORMAL] = mesh_data.normal_array
	arrays[Mesh.ARRAY_TEX_UV] = mesh_data.uv_array
	arrays[Mesh.ARRAY_INDEX] = mesh_data.index_array
	
	call_deferred("_update_mesh", arrays)

func _update_mesh(arrays : Array):
	var _mesh := ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = _mesh
