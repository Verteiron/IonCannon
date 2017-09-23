# Orbital Ion Cannon
### Death strikes from above in a distinctly non-lore-friendly fashion!

Requested by Steam user Blast Lord.

## Version 1.0.0: Public release

Initial (beta) release.

## How to Use
When you load the game after installing the mod, you will automatically gain 2 Destruction spells and a lesser Power. 

### Power: Ion Cannon Blast
The area under your crosshairs will be struck with an Ion Cannon blast after about 3 seconds.

### Spell: Ion Cannon Rune
Create a giant, ugly, purple rune on the ground. It will react like normal runes, except instead of exploding, it will call down an Ion Cannon blast after about a second.

### Spell: Ion Cannon Remote Target
Place it like a rune. Run away and cast it a second time to call an Ion Cannon strike down on the target's position.

## Notes

After each beam blast there will be a short delay while the Ion Cannon recharges. Only one place can be targeted at a time, so if you place the rune, set it off, activate the remote target, and use the Power, you'll still only get one blast. Doing this is a good way to screw up the animation, too.

## Compatibility

Should be pretty universal. Does not share assets with anything else. If your scripting engine has been hosed by another mod, the spell will not cast correctly.

## Troubleshooting

If the spell hangs during casting, i.e. the targeting beams locked on but the blast never comes, just cast it somewhere else. If it won't let you, then hit T and wait an hour to reset the spell objects. 

If the Ion Cannon is totally broken, or you accidentally removed the spells from your character somehow, type the following in the console:

```set vION_Reset to 1```

then quicksave and quickload. This will reset all spell objects, along with the control script/Quest, and re-add the spells to your character if needed.

## FAQ

Q. One of the dev videos showed multiple beams simultaneously. Why is there only one at a time now?
A. Originally this effect worked by dynamically creating and deleting objects. Unfortunately, some of these referenced each other in such a way that there's a danger they'd never by cleared by Skyrim and thus they'd clutter up your save forever, causing bloat. To fix this I made all the objects permanently reside in an empty Cell and now move them around instead of creating and deleting them. Unfortunately this means they can only exist in one place at a time now, hence the limit.

## Credits

Thanks to Blast Lord on Steam for the original request.

Many thanks to [cubicApocalypse](http://freesound.org/people/cubicApocalypse/) on freesound.org for the following audio:

* [x_explosion.wav](http://freesound.org/people/cubicApocalypse/sounds/256658/) - modified slightly to remove the double explosion. Original sound is copyrighted by [cubicApocalypse](http://freesound.org/people/cubicApocalypse/) and is licensed under CC BY 3.0.
