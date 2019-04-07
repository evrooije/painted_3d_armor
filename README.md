### [Mod] 3D Armor Painted Banners [painted_3d_armor]
This mod bridges Hybrid Dog's version of the painting mod with stu's 3d_armor modpack and allows paintings to be used as a banner/ crest/ sigil/ coat of arms on your armor. How does it work? It adds an extra 6x6 painting canvas that can be placed on the easel and painted. The painting has been given an armor group so that it can be added to the detached armor inventory of 3d_armor. Once added there, the painting's texture is added as an overlay on the player's skin, on the chest plate if the player is wearing one and if the player holds a shield the image is placed on the shield as well.

### Installing
Install the painting mod (https://github.com/evrooije/painting), the banners mod (https://github.com/evrooije/banners), 3d_armor (https://github.com/stujones11/minetest-3d_armor) and this mod by downloading them as zip or cloning, e.g.:

```
git clone https://github.com/evrooije/painting
git clone https://github.com/evrooije/banners
git clone https://github.com/stujones11/minetest-3d_armor
git clone https://github.com/evrooije/painted_3d_armor
```

Once installed you now have the painting mod's easel and canvases at your disposal, as well as a special armor banner. To use painting, craft an easel and then craft the 6x6 armor canvas as per the crafting recipes. Place the easel and left click the easel with the armor canvas. Craft the brushes for the colors you need and start painting by right clicking on the canvas. Once done, walk to the side or the back of the canvas and dig it (digging it from the front does not work as the painting mod places an entity there which blocks digging).

Once the canvas is in the inventory, open inventory and switch to the armor page. Now place the painted canvas into a free slot and the painting is added to your armor, shield and even your player skin in case you are not wearing any armor.

To use banners, craft a armor banner and left click to open the banner formspec. Once you are done creating a banner, double click outside of the formspec (DO NOT HIT ESC!!) to save the changes to the banner. You can now place the armor banner into the free armor slot.

### How to Customize
#### Canvas Sizes
The painting mod comes with multiple canvases that can be painted (16x16, 32x32, 64x64). Obviously images of that size cannot be added to the player texture as there is limited space available in the skin. The result would be that only the top left part of the image is shown. You can ignore this of course, or you could remove the crafting recipes for the larger canvas sizes. There is no easy other way to fix this, since there is only one craft item registered for the painted canvas (so all canvas sizes end up being one craft item once dug from the easel). As this mod tries *not* to interfere with the other mods, no separate craft item could been created for the armor canvas and even if I wanted to, it would mean copying a lot of code from the original painting mod.

So I suggest you remove the crafting recipes for the larger canvases from your copy of the painting mod or leave as is if you would still like to use the other canvas sizes for e.g. pictures on the wall or painted banners as nodes in the world.

#### Banners on Player Skins
You may not like the banner on the player skin. But please consider that you can leave the choice up to the player to simply remove the painted canvas from the amor inventory or leave it in if they like to have the banner on their player skin. If you still would like to disable the overlay when the chest plate is not worn, then you can set the overlayOnSkin variable to false in init.lua. The config works as follows (including shield for completeness sake):

```
               |  overlayOnSkin = true         |  overlayOnSkin = false
No Chest Plate |  Chest plate banner is shown  |  Chest plate banner is not shown
Chest Plate    |  Chest plate banner is shown  |  Chest plate banner is shown
No Shield      |  Shield banner is not shown   |  Shield banner is not shown
Shield         |  Shield banner is shown       |  Shield banner is shown 
```

#### Removing Shields
You should be able to safely remove the shields mod as there are not hard references to it and it checks for the existence of the armor group property before doing anything else. So if you did not want shields in the first place, you can safely disable/ remove.

#### Crafts
Customizing the crafts can be done as you like, but remember that if you e.g. would like to replace the paper used for the armor canvas and use something like hemp, you may want to change that for the recipes in the painting mod as well (or not if you want armor canvas to be created from e.g. metal to make it more like an "armor recipe" of course).

### References
https://forum.minetest.net/viewtopic.php?f=9&t=18178
https://forum.minetest.net/viewtopic.php?f=9&t=15305
https://forum.minetest.net/viewtopic.php?f=11&t=2588
https://forum.minetest.net/viewtopic.php?f=11&t=4654
