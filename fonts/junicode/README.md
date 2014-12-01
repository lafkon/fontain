JUNICODE
========
CLASSIFICATION: Serif


GENERAL INFORMATION
===================

> Junicode is and always will be free. 
> This means that you can use it without 
> charge in any publication, print or electronic, 
> and you may adapt the font for your own use 
> and even distribute your adaptation, 
> as long as you obey the terms of the license.
> [->](http://junicode.sourceforge.net/)


AUTHOR
======
[Peter S. Baker](http://www.engl.virginia.edu/people/psb6m)


LICENSE
=======
[SIL Open Font License (OFL)](http://scripts.sil.org/OFL)


FONTAIN HOWTO
=============


TEX HOWTO
=========

- Unzip junicode.tex.zip

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
  junicode.texmf.zip to your TEXMFHOME directory
  (copy over existing folders)

- Add the line `Map pju.map`
  to the file $TEXMFHOME/web2c/updmap.cfg
  (If the file/directory does not exist create it!)

- Update your TeX installation
 `updmap`

- Compile the testpage example_junicode.tex    
 `pdflatex example_junicode.tex`

### Future

- [Get started with LaTeX](http://en.wikibooks.org/wiki/LaTeX)
- Use `\fontfamily{pju}\selectfont` to select Junicode
  during a LaTeX document
- Start to love LaTeX!

TEX CONFIGURATION
=================
KARLBERRYNAME:pju
FOUNDRY:peterbaker
TEXSRCREGULAR:junicode_regular
TEXSRCITALIC:junicode_italic
TEXSRCBOLD:junicode_bold
TEXSRCBOLD-ITALIC:junicode_bold-italic

