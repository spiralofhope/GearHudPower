# GearHUDPower

GearHUDPower is a World of Warcraft AddOn (Lua).

It is a hackish modification of [warbaby's](http://www.curseforge.com/profiles/warbaby/) AddOn [GearHUD](http://wow.curseforge.com/addons/gear_hud/) to show power instead of health.

It simulates the Gears of War cog/skull health indicator, but for power.

GearHUD and GearHUDPower can both run at the same time.

`GEAR_HUD_POWER.tga` is derived from the [Epic Games](http://en.wikipedia.org/wiki/Epic_Games)' [Gears of War](http://en.wikipedia.org/wiki/Gears_of_War).

# Customization

Edit `World of Warcraft/Interface/AddOns/GearHUDPower/GearHudPower.lua` to make changes.  Additional instructions will be found in there.

```
GearHudPower_threshhold = { 75, 50, 25, 10, 5 };
GearHudPower_offset = { 0, 40 };
GearHudPower_scale = 1.5
```

## Editing the image

Edit `World of Warcraft/Interface/AddOns/GearHUDPower/GEAR_HUD_POWER.tga`

You can change the colour or even the graphic.

# Usage

- `/gearhud` or `/gh` to lock/unlock.
- `/gearhud` or `/gh reset` to reset to default.
- Right-click the resize handler to lock.

# TODOs and known bugs

[GearHudPower.lua](https://github.com/spiralofhope/GearHUDPower/blob/master/GearHudPower.lua) will have such lists.  Also search for FIXME, TODO.
