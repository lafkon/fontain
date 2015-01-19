fontain
=======

a [font-collection-system](https://github.com/lafkon/fontain) 
and a [font-collection](http://www.fontain.org).


**fontain** is a collection of f/l/os compatible fonts (as fontforge 
sources) and a collection of utilities to transform the sources into popular font formats 
and create an interface to browse the collection online or locally.

- `.otf       ` = [OpenType](http://en.wikipedia.org/wiki/OpenType)
- `.ttf       ` = [TrueType](http://en.wikipedia.org/wiki/TrueType)
- `.ufo.zip   ` = [Unified Font Object](http://unifiedfontobject.org/)
- `.eot  `      = [Embedded OpenType](http://en.wikipedia.org/wiki/Embedded_OpenType)
- `.woff `      = [Web Open Font Format](http://en.wikipedia.org/wiki/Web_Open_Font_Format)
- `.svg  `      = [Scalable Vector Graphics](http://en.wikipedia.org/wiki/Web_typography#Scalable_Vector_Graphics)
- `.css  `      = [Cascading Style Sheets](http://en.wikipedia.org/wiki/Cascading_Style_Sheets)
- `.texmf.zip ` = font files prepared to use with your [TeX](http://en.wikipedia.org/wiki/TeX) distribution

**fontain** has been developed and tested on [Debian, the universal operating system](https://www.debian.org/)
and [Ubuntu](http://www.ubuntu.com/).
**fontain** uses [fontconvert](https://gitorious.org/manufacturaindhacks/tinytypetools/source/fontconvert) and 
[ttf2eot](https://github.com/metaflop/ttf2eot).

The browser **ui** uses 
[Skeleton V1.2](http://www.getskeleton.com/), 
[rangeslider.js](https://github.com/andreruffert/rangeslider.js), 
[jquery](), 
...

**fontain** is inspired by [Use & Modify](http://usemodify.com/), respectively [ofont](https://github.com/raphaelbastide/ofont).


### MK_FONTS.SH HOWTO

`mk_fonts.sh` creates derivative formats from the fontforge source.

- install fontforge
- compile ttf2eot
- install texlive-font-utils


### MK_UI.SH HOWTO

`mk_ui.sh` creates static html that can be used to browse the font collection,
either local or online.


### GENERAL HOWTO

Get a list of all font sources (may be used as selection in README)    
`find . -name "*.sfdir" -type d | rev | cut -d "/" -f 1 | rev | sed 's/.sfdir//g'`


### ONLINE CONFIGURATION

To allow local browsing we add index.html to the links.
If you prefer to have this removed for the online version
and use an apache web server add this to you `.htaccess`:

    RewriteEngine On
    RewriteCond %{REQUEST_URI} index\.html
    RewriteRule ^(.*)index\.html$ /path/to/fontain/$1 [R=301,L]



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


FONT STYLES
===========

source-code-pro_light
  pressuru
medio_regular
kaushan-script_regular
arimo_bold
aileron_semibold
vegur_bold
nimbus-sans-l_regular
dancing-script_regular
beon_regular
lilgrotesk_bold
junction_regular
junction_bold
junction_light
raleway_thin
  junicode_regular-italic
junicode_regular
  junicode_bold-italic
  junicode_bold
basic_regular
sean_book
  sean_ultralight
  sean_extrabold
  sean_bold
  sean_medium
  sean_ultrabold
  sean_semibold
  sean_light
  sean_normal
helvetia-verbundene
  fira-sans_four
grobe-deutschmeister
victors
pt-serif_italic
ocr-a
standard-graf_regular
  fira-sans_italic
  fira-sans_four-italic
  fira-sans_medium
  fira-sans_extrabold
  fira-sans_eight
  fira-sans_heavy
  fira-sans_two
  fira-sans_two-italic
  fira-sans_light-italic
  fira-sans_hair-italic
  fira-sans_thin-italic
  fira-sans_ultra
  fira-sans_light
  fira-sans_ultralight-italic
  fira-sans_book
  fira-sans_eight-italic
  fira-sans_heavy-italic
  fira-sans_hair
  fira-sans_book-italic
  fira-sans_bold
  fira-sans_extralight
  fira-sans_semibold
  fira-sans_ultra-italic
  fira-sans_semibold-italic
  fira-sans_extralight-italic
fira-sans_regular
  fira-sans_bold-italic
  fira-sans_thin
  fira-sans_medium-italic
  fira-sans_ultralight
  fira-sans_extrabold-italic
  pt-serif_caption
  pt-serif_bold-italic
  pt-serif_caption-italic
  pt-serif_bold
  pt-serif_regular

