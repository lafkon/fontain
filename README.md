fontain
=======

a [font-collection-system](https://github.com/lafkon/fontain) 
and a [font-collection](http://fountain.x).


fontain is a collection of f/l/os compatible fonts (as fontforge 
sources) and utilities to transform the sources into popular font formats 
and create an interface to browse the collection online.

- `.otf       ` = [OpenType](http://en.wikipedia.org/wiki/OpenType)
- `.ttf       ` = [TrueType](http://en.wikipedia.org/wiki/TrueType)
- `.ufo.zip   ` = [Unified Font Object](http://unifiedfontobject.org/)
- `.eot  `      = [Embedded OpenType](http://en.wikipedia.org/wiki/Embedded_OpenType)
- `.woff `      = [Web Open Font Format](http://en.wikipedia.org/wiki/Web_Open_Font_Format)
- `.svg  `      = [Scalable Vector Graphics](http://en.wikipedia.org/wiki/Web_typography#Scalable_Vector_Graphics)
- `.css  `      = [Cascading Style Sheets](http://en.wikipedia.org/wiki/Cascading_Style_Sheets)
- `.texmf.zip ` = files prepared to use with your [TeX](http://en.wikipedia.org/wiki/TeX) distribution

fontain has been developed and tested on [Debian, the universal operating system](https://www.debian.org/)
and [Ubuntu](http://www.ubuntu.com/).
fontain uses [fontconvert](https://gitorious.org/manufacturaindhacks/tinytypetools/source/fontconvert) and 
[ttf2eot](https://github.com/metaflop/ttf2eot).

The browser **ui** uses 
[Skeleton V1.2](http://www.getskeleton.com/), 
[rangeslider.js](https://github.com/andreruffert/rangeslider.js), 
[jquery](), 
...

 fontain is inspired by [Use & Modify](http://usemodify.com/).





## Required Software

### mk_fonts.sh

`basename (GNU coreutils) 8.13`    
 strip directory and suffix from filenames    

`cp (GNU coreutils) 8.13`    
 copy files and directories    

`cut (GNU coreutils) 8.13`    
 remove sections from each line of files    

`echo (GNU coreutils 8.12.197-032bb September 2011)`    
 display a line of text    

`exit (Linux 2009-09-20)`    
 cause normal process termination    

`grep  2.12-2`    
 GNU grep, egrep and fgrep    

`fontconvert`([lib/tools/tinytypetools/fontconvert](lib/tools/tinytypetools/fontconvert))    
 A script to convert any font to a set of different formats.    
 Requires Fontforge and ttf2eot.

`head (GNU coreutils) 8.13`    
 output the first part of files    

`ls (GNU coreutils) 8.13`    
 list directory contents    

`md5sum (GNU coreutils) 8.13`    
 compute and check MD5 message digest    

`mkdir (GNU coreutils) 8.13`    
 make directories    

`mv (GNU coreutils) 8.13`    
 move (rename) files    

`pltotf (Web2C 2012 27 December 1992)`    
 convert property list files to TeX font metric (tfm) format    

`rev from util-linux 2.20.1`    
 reverse lines of a file or files    

`rm (GNU coreutils) 8.13`    
 remove files or directories    

`sleep (GNU coreutils) 8.13`    
 delay for a specified amount of time    

`tex (Web2C 2012 1 March 2011)`    
 text formatting and typesetting    

`ttf2eot`([lib/tools/ttf2eot](lib/tools/ttf2eot))    
 commandline wrapper around OpenTypeUtilities.cpp from Chromium

`vptovf (Web2C 2012 16 December 1994)`    
 convert virtual property lists to virtual font metrics    

`wc (GNU coreutils) 8.13`    
 print newline, word, and byte counts for each file    

`zip  3.0-6`    
 Archiver for .zip files    




### mk_ui.sh


`awk (Free Software Foundation Nov 10 2011 GAWK(1))`    
 pattern scanning and text processing language    

`basename (GNU coreutils) 8.13`    
 strip directory and suffix from filenames    

`cat (GNU coreutils) 8.13`    
 concatenate files and print on the standard output    

`cp (GNU coreutils) 8.13`    
 copy files and directories    

`cut (GNU coreutils) 8.13`    
 remove sections from each line of files    

`echo (GNU coreutils 8.12.197-032bb September 2011)`    
 display a line of text    

`egrep (GNU grep) 2.12`    
 print lines matching a pattern    

`exit (Linux 2009-09-20)`    
 cause normal process termination    

`expr (GNU coreutils) 8.13`    
 evaluate expressions    

`grep  2.12-2`    
 GNU grep, egrep and fgrep    

`head (GNU coreutils) 8.13`    
 output the first part of files    

`inkscape  0.48.3.1-1.3`    
 vector-based drawing program    

`ls (GNU coreutils) 8.13`    
 list directory contents    

`mkdir (GNU coreutils) 8.13`    
 make directories    

`mv (GNU coreutils) 8.13`    
 move (rename) files    

`pandoc  1.9.4.2-2`    
 general markup converter    

`rev from util-linux 2.20.1`    
 reverse lines of a file or files    

`rm (GNU coreutils) 8.13`    
 remove files or directories    

`sed  4.2.1-10`    
 The GNU sed stream editor    

`sort (GNU coreutils) 8.13`    
 sort lines of text files    

`tail (GNU coreutils) 8.13`    
 output the last part of files    

`tr (GNU coreutils) 8.13`    
 translate or delete characters    

`wc (GNU coreutils) 8.13`    
 print newline, word, and byte counts for each file    

`zip  3.0-6`    
 Archiver for .zip files    

