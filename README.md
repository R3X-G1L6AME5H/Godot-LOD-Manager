# Open World LOD Manager
## In summary...
A simple LOD plugin for Godot. It's a tool to manage world maps more easly. It works recursively, meaning it can manage LOD Objects under other LOD Objects. This way you don't have to worry about managing every single prop. It will be hidden automatically when it's parent is hidden; Only the relevant objects are shown on the screen.

## Usage...
There are only two scripts in this plugin. The `LODManager.gd` and `LODObject.gd`. You put `LODManager.gd` on a `Spatial` node, and then put every static object under it. The manager will process anything with the `visible` property; a `MeshInstace` for example. The objects need to have either one of "-lod1", "-lod2", "-lod3" suffixes on it, else the Manager will ignore it. "-lod1" objects are of highest quality, and "-lod3" objects are less so.

You will notice a couple of properties in the Inspector when you select the Manger node. `Track Target` is ment for in-editor review. You pick a `Spatial`, or a `Position3D` node and the Manager will treat it as it would treat a player in-game. But before you can review your work, you need to build the map, which you do by ticking the `Build` property(if it unticks itself, then that means its working properly, otherwise, close your scene and open it again). Now that the map is built, you can review how it will look in-game by ticking the `Track` node. The behavior will depend on the Default LOD sliders, as you might imagine. While there is nothing preventing you, keep in mind that the script **won't work** if the condition __LOD1 < LOD2 < LOD3__ isn,t satisfied. **Remember to rebuild the map once you edit your LOD's!**

Finally, if you were paying attention, you might have noticed how the `Fade` tick was skipped. This is because I don't reccomend using it. The idea behind it is to smoothly fade between the LOD's. It works, but the benefit of it doesn't feel worth the cost. For the fade to work, it needs to access the material, and change the ALPHA value to control its transparency. If you tried it right now, you would notice that everything would disappear. This is probably because you used the same material on every object. For it to work as intended, you need to make the material unique on EVERY instance. Very time consuming, if not incredibly memory inefficient. **Use at your own discretion.**

## In practice...
Let me take you through the process of using this plugin, so that you may better comprehend how it works.
