
Fontconvert
===========

This is a modest Python script to convert a font into a set of formats.

The main purpose is to grab a .sfd file and output all the formats necessary for webfont use, which happen to be more than enough for most other uses as well.

Dependencies
------------

You need Fontforge compiled with Python support. 
Most distros will come with this out of the box through their package manager.

You'll also require the ttf2eot command line utility in order to output to EOT (Embedded OpenType).
You can find the application at http://code.google.com/p/ttf2eot/ , along with instructions on how to compile it.
Place the ttf2eot binary anywhere in your PATH, and you're set.

Supported formats
-----------------

Fontconvert can open any format that Fontforge supports.

  http://en.wikipedia.org/wiki/FontForge#Supported_font_formats

It outputs to the following formats:

  * .ttf - Truetype
  * .otf - OpenType
  * .woff - Web Open Font Format
  * .ufo - Unified Font Object
  * .svg - SVG font
  * .eot - Embedded OpenType

Usage
-----

You can use Fontconvert to convert to a single format, or all supported formats. For this, use the available arguments in the command-line tool:

    -w, --woff  Save in WOFF format (.woff)
    -o, --otf   Save in OpenType format (.otf)
    -t, --ttf   Save in TrueType format (.ttf)
    -s, --svg   Save in SVG Font format (.svg)
    -e, --eot   Save in Embedded OpenType format (.eot)
    -u, --ufo   Save in UFO format (.ufo)

For example, if you have Douar.sfd and want to output OTF, TTF and WOFF versions, you could type

    fontconvert Douar.sfd --otf --ttf --woff

Or, more simply,

    fontconvert Douar.sfd -otw

License
-------

Fontconvert is (c) 2012 Manufactura Independente (Ana Carvalho & Ricardo Lafuente)
Licensed under the GPL v3 or later version.
