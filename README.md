# Open World LOD Manager
## In summary...
A simple LOD plugin for Godot. It's a tool to manage world maps more easly. It works recursively, meaning it can manage LOD Objects under other LOD Objects. This way you don't have to worry about managing every single prop. It will be hidden automatically when it's parent is hidden; Only the relevant objects are shown on the screen.

## Usage...
There are only two scripts in this plugin. The `LODManager.gd` and `LODObject.gd`. You put `LODManager.gd` on a `Spatial` node, and then put every static object under it. The manager will process anything with the `visible` property; a `MeshInstace` for example. The objects need to have either one of "-lod1", "-lod2", "-lod3" suffixes on it, else the Manager will ignore it. "-lod1" objects are of highest quality, and "-lod3" objects are less so.

You will notice a couple of properties in the Inspector when you select the Manger node. `Track Target` is ment for in-editor review. You pick a `Spatial`, or a `Position3D` node and the Manager will treat it as it would treat a player in-game. But before you can review your work, you need to build the map, which you do by ticking the `Build` property(if it unticks itself, then that means its working properly, otherwise, close your scene and open it again). Now that the map is built, you can review how it will look in-game by ticking the `Track` node. The behavior will depend on the Default LOD sliders, as you might imagine. While there is nothing preventing you, keep in mind that the script **won't work** if the condition __LOD1 < LOD2 < LOD3__ isn,t satisfied. **Remember to rebuild the map once you edit your LOD's!**

Finally, if you were paying attention, you might have noticed how the `Fade` tick was skipped. This is because I don't reccomend using it. The idea behind it is to smoothly fade between the LOD's. It works, but the benefit of it doesn't feel worth the cost. For the fade to work, it needs to access the material, and change the ALPHA value to control its transparency. If you tried it right now, you would notice that everything would disappear. This is probably because you used the same material on every object. For it to work as intended, you need to make the material unique on EVERY instance. Very time consuming, if not incredibly memory inefficient. **Use at your own discretion.**

## In practice...
Let me take you through the process of using this plugin on a practical example, so that you may better comprehend how it works. For this example I shall demonstrate how to make a game map. For simplicity's sake, this map will be procedually generated.

### Step 1
To create the meshes for our map we shall use Blender. For the first step, open up blender, delete everything in the scene and create a plane with `Shift + A`.

![Image 1](https://raw.githubusercontent.com/R3X-G1L6AME5H/Godot-LOD-Manager/master/Example/Assets/DEMO_IMG/Step_1.PNG)

### Step 2
Select the plane and go to its modifer tab. Add a Subdivision Surface modifier, and make it Simple like I did in the screenshot below. Next, add a Displacement modifier. Set its coordinates to Global,  Direction to Z, and Space to Global. First modifier will control the detail of our mesh, and the latter one will create the terrain. Most important setting here is the Coordinates option. With this set to global, if you moved the plane, it would map the terrain accordingly. 

![Image 2](https://raw.githubusercontent.com/R3X-G1L6AME5H/Godot-LOD-Manager/master/Example/Assets/DEMO_IMG/Step_2.PNG)

Now, you CAN create a terrain with any displacement map, but, again, for simplicity's sake this map will be procedually generated. The way we're gonna do that, is by creating a new texture, and in the texture tab, change the type from Single Image to Voronoi. You can change options here to make it more appealing.

### Step 3
The next step is to make the meshes with the different levels of detail. Select the previously created plane and press `Shift + D`, to duplicate it. Do this once more so that you have 3 planes overlapping. Name them like I did in Image 3: __"LOD1.001"__, __"LOD2.001"__, and __"LOD3.001"__. You can even put them in sepparate collections for easier management.  

![Image 3](https://raw.githubusercontent.com/R3X-G1L6AME5H/Godot-LOD-Manager/master/Example/Assets/DEMO_IMG/Step_3.PNG)

### Step 4
Select the __LOD3.001__ plane and make its Subdivision Modifier have less subdivisions than __LOD2.001__, and __LOD2.001__ less than __LOD1.001__. Now you have 3 Levels of Detail. All that remains is to expand our map. You do this by selecting the 3 planes and pressing `Shift + D` to duplicate them. BUT, before you place the copy, press number `2`. This will move the copy by 2 units along the X axis, like you see in the Image bellow. Do this a few times till you get as many chunks as you need. 

![Image 4](https://raw.githubusercontent.com/R3X-G1L6AME5H/Godot-LOD-Manager/master/Example/Assets/DEMO_IMG/Step_4.PNG)

### Step 5
Then select all those planes, duplicate them, press number `2`, AND the `y` key. This will move the copies down the Y axis. And finaly, you'll have the grid of chunks like in the image below. The great thing about this method is that you can now alter your displacement texture, and it will update your chunks real-time.

![Image 5](https://raw.githubusercontent.com/R3X-G1L6AME5H/Godot-LOD-Manager/master/Example/Assets/DEMO_IMG/Step_5.PNG)

### Step 6
Your map is now ready for export. Export it as a glTF file. Its IMPORTANT to tick the `Apply Modifiers` box.

![Image 6](https://raw.githubusercontent.com/R3X-G1L6AME5H/Godot-LOD-Manager/master/Example/Assets/DEMO_IMG/Step_6.PNG)

