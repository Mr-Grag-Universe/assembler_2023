## Picture processing

In this lab I insert assembly function to C-code and also checked the time, my program process pictures.
This program turns picture grey or only right-top half: you can chose this and also shall program use assembly
insertion or not by passing corresponding comand line param. Program running looks like this:
Just turn grey:
> app picture.png grey_picture.png

Turn only half:
> app picture.png grey_picture.png strange

You can build program with or without using asm insertion:
> make asm_func=INCLUDE_ASM_FUNC

or:
> make asm_func=not_INCLUDE_ASM_FUNC

or pass nothing.
Also if you just write make, it will build all optimisation vertions of this app.
You can pick a version for building by using optimize index after app like this:
> make app{0/1/2/3/fast}
