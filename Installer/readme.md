This is my first try at a serious windows application.
It is intended to be an installation wizard.
There is no handy interface for creating an installation file, though,
it must be created by hand using the routines in Combine.ew:

add_package() & add_file()

First add_package("sample_name")
Then add_file(1,"test.txt")

If you add a second package you can add_file(2,"test2.txt")

After adding all the packages and files you want:

save_install("mystuff.dat")

This creates a compressed file named mystuff.dat that can be installed
by install.exw

Now edit the first line of install.exw so that name equals the name
of your installation file.

Finally, by opening Install.exw you can install the packages anf files.

This isn't my best piece of code, I am better at DOS programs, but
you may find this program interesting.
