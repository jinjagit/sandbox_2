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


Refactoring the stats text display taught me that triggering actions in another script may not be as simple as calling a function in that script.
In this case the called function set a global variable in the script, but although the variable was set locally (to the function), it did not set the global value (even when the variable was exported).
What I needed to do was introduce another exported global variable, and set it directly via a variable set to the get_node of the target node, then have the physics process in the target node check for that set value constantly, call the local target function if the value is true and immediately set the value back to false. This 'trigger var' pattern seems like it will be useful! (see: CanvasLayerUI.gd)

Jitter: Tried moving planet and camera rotations to physics_process, but seems to make no difference. Maybe will try the smoothing plugin.
EDIT: Tried the plugin. Not sure it makes much/any difference (but maybe a litle). What seemed to help most was not running with 2 screens (different refresh rates?)
https://godotmarketplace.com/shop/smoothing-node/
https://github.com/lawnjelly/smoothing-addon

EDIT: I noticed that my LG external monitor was stuck at 30Hz, no matter the chosen resolution. After some reading about Macs and monitors, I switched to using a DisplayPort<->USB C cable, and now the jittering and stuttering is greatly reduced, even when spinning a 256x256 vertex faced cubesphere. I also, however, noticed that using the Mac screen as a mirror of the external screen cuases the stutter to return (whereas using it as an extended screen does not). Also, setting the Mac screen as a mirror, but then closing the laptop lid removes the stuttering on the external display. So, probably, it's just some kind of display driver / resource overload issue when trying to run the Mac screen a s a mirror of the external screen. The FPS display conditional check still seems to introduce stutter, even when false! This needs more investigation.