OCR-A
=====
CLASSIFICATION: Sans-Serif Monospaced


GENERAL INFORMATION
===================
The OCR-A font was developed by the American National Standards Institute (ANSI)
to be readable by the computers of the 1960s.  The OCR-A font is still used
commercially in payment advice forms so that a lockbox company can determine 
the account number and amount owed on a bill when processing a payment.  
A site license for the OCR-A font is very expensive, so I undertook to create 
a free font.  I started with the MetaFont definitions, used FontForge and potrace 
to construct a TrueType font, then assigned each glyph a Unicode code point.  
I visually compared the resulting character shapes with ANSI X3.17-1977.

To use the OCRA font with Microsoft Windows, download file OCRA.ttf and drop 
it in your fonts folder.  To print with it, choose font OCRA and size 10 point.

The other files in this project will be of interest to those who
wish to modify the font.  The shape of each glyph was defined by ANSI as
described in their document ANSI X3.17-1977.  Those shapes were coded
in the MetaFont language as strokes by Tor Lillqvist and Richard B. Wales.
Their work is in the .MF files under MetaFont Sources.  The MetaFont program
and the OCR font definitions are available as part of the TeX package from 
the CTAN archive.

I compiled the OCR-A font into a large bitmap to make edge finding easier; 
that file is ocr10.pk.  I then loaded ocr10.pk into FontForge, which is
available on SourceForge, as background images.  From FontForge I used
potrace, also available on SourceForge, to trace outlines around the bitmaps.
I then assigned a Unicode code point to each glyph.  Mostly they were
obvious, but Unicode does not make provision for the "alternate glyphs"
of ANSI X3.17-1977, so I found some reasonable places to put them.
If Unicode ever adds the "alternate glyphs" of ANSI X3.17-1977 to
their OCR page, the assignments should be updated.  The resulting file
is OCRA.sdf, which can be read by FontForge if you want to modify the
character shapes or change the Unicode code points.

ANSI specifies a character spacing of between 0.09 and 0.18 inch.
I chose 0.1 inch, since that seems to be a common spacing.

FontForge is able to write both PostScript and TrueType font files, 
so I wrote both.  OCRA.afm, OCRA.pfa and OCRA.pfb are the PostScript
font files, and OCRA.ttf is the TrueType font file.  Windows users need
only be concerned with the OCRA.ttf file.  Simply drop it into the fonts
directory and they can print using the OCR-A font by selecting 10-point
size.

The American National Standards Institute makes the X3.17-1977 document
available on their web site for a modest fee.  I purchased that document
so I could compare the font I am publishing with the official definition.
I found an exact match, which speaks well for the efforts of Tor Lillqvist
and Richard B. Wales, since I made no manual changes in the bitmaps or
the character shapes constructed by potrace.  I would like to have included
the X3.17-1977 document in this project, for completeness, but ANSI has
copyrighted it so I cannot.

There is an article on Wikipedia about the OCR-A font.
    John Sauter (John_Sauter@systemeyescomputerstore.com)
    February 4, 2010


http://sourceforge.net/projects/ocr-a-font/
Not sure about License


AUTHOR
======
[John Sauter](http://www.systemeyescomputerstore.com/)


LICENSE
=======
TODO


UI CONFIGURATION
================
AKKORDEON
DOWNLOAD
AUTHOR
LICENSE
FLOWTEXT
SPECIMEN



FONTAIN HOWTO
=============



TEX HOWTO
=========

- Unzip ocr-a.tex.zip

### For the first time

- Install LaTeX (texlive-latex-base)
  e.g. `sudo aptitude install texlive-latex-base`
 _or_ use the software center
 _or_ download it from the internet.

- Find out about your TEXMFHOME directory
 `kpsewhich --var-value=TEXMFHOME`

#### Approach **1**

- If there is no TEXMFHOME directory create it
  e.g. `mkdir ~/.TEXMF`
- and add it to your configuration
 `sudo tlmgr conf texmf TEXMFHOME "~/.TEXMF"`

#### Approach **2**

- `cd /etc/texmf/texmf.d`
- `sudo touch 00_texmfhome.cnf`
- `sudo echo "TEXMFHOME = ~/.TEXMF" > 00_texmfhome.cnf`
- `sudo update-texmf`
- `kpsexpand \$TEXMFHOME`

#### Untested

- Windows: [Create a local texmf tree in MiKTeX](http://tex.stackexchange.com/questions/69483/create-a-local-texmf-tree-in-miktex)
- Mac OSX: [How to make LaTeX see local texmf tree](http://tex.stackexchange.com/questions/30494/how-to-make-latex-see-local-texmf-tree)

### To install the font

- Add the content of the TEXMF directory inside
  ocr-a.texmf.zip to your TEXMFHOME directory
  (copy over existing folders)

- Add the line `Map ocr.map`
  to the file $TEXMFHOME/web2c/updmap.cfg
  (If the file/directory does not exist create it!)

- Update your TeX installation
 `updmap`

- Compile the testpage example_ocr-a.tex    
 `pdflatex example_ocr-a.tex`

### Future

- [Get started with LaTeX](http://en.wikibooks.org/wiki/LaTeX)
- Use `\fontfamily{ocr}\selectfont` to select OCR A
  during a LaTeX document
- Start to love LaTeX!




TEX CONFIGURATION
=================
KARLBERRYNAME:ocr
FOUNDRY:johnsauter

TEXSRCREGULAR:ocr-a

