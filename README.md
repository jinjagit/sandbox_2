# Sandbox_1
Starting point: [Sandbox_1 repo](https://github.com/jinjagit/sandbox_1)  
  
## Aims
- [ ] Simplify and separate concerns in calculating arrays for, and rendering of, meshes
- [x] Toggle visibility of cubesphere face meshes individually
- [x] Add more controls for rotation
- [ ] Only recalculate the arrays that need recalculating when applying noise to meshes
- [ ] Start mixing in Rust and try some parellelism to improve performance
- [ ] Create textures using noise and match to noise applied to meshes

## Notes
Currently using these normals for each cube face:

Name (x, y, z)

Up (0, 1, 0) Down (0, -1, 0) Left (-1, 0, 0) Right (1, 0, 0) Back (0, 0, -1) Front (0, 0, 1)
