An iOS Go App run katago in CoreML

# [KatagoObjC](https://github.com/hlstwizard/KatagoObjC)
Put it in the parent folder of this project.

# SGF using Antlr4

Steps 1, 2 might not be needed if there is no customization of sgf.g4.

	1. Install anltr4 (The location in Makefile might need to be changed as well)

	2. run `make` will regenerate the files.

	3. Add the antlr4 runtime.
		a. Checkout the antlr4 source code in the parent folder of this project.
		b. Check if the Antlr4 package is loaded in the Packages folder.

