# arrrg
ARRRG
My friend and I made this while bored at work. It's a two player pirate ship fight that runs on the command line because why not.

--IMPORTANT--
To play the game, run pirate.exe

Powershell might ask if you want to change your execution policy, which essentially just allows our custom script to run.
If you don't trust us you can always look at the included source code to see that this isn't a virus.

If the two windows don't fit on the screen very well, all you have to do is right click where it says "windows powershell" in the top
left of the window, select properties, go to the 'font' tab, and bring the font size down.  This will change the default for the next
time you run powershell, but just repeat the process to change the font back to normal size.
--IMPORTANT--




The source code is included in case you want to laugh at how bad we are at coding, or add stuff for some reason.
ALSO you have to run the following command in powershell if you plan on running this from the source code:

```powershell
> Set-Executionpolicy Unrestricted
```

Then to play the game type
```powershell
> .\pirate.ps1
```

I promise it's fine.  If you're worried about that, after you're done you can run:

```powershell
> Set-Executionpolicy Restricted
```

That puts the training wheels back on.
