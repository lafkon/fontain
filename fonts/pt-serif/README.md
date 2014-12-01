PT-SERIF
========
CLASSIFICATION: Serif


GENERAL INFORMATION
===================
Pan-Cyrillic font superfamily PT Sans – PT Serif developed for the project “Public Types of Russian Federation”.

> Font families PT Sans and PT Serif were released in 2009–2010 with open user license. 
> The main aim of the project is to give possibility to the peoples of Russia to read 
> and write on their native languages. The project is dedicated to 300-year anniversary 
> of the civil type invented by Peter the Great in 1708–1710 years and was realized 
> with financial support from Federal Agency for Press and Mass Communications.

PT Serif is a transitional serif face with humanistic terminals designed for use together 
with PT Sans and harmonized with PT Sans on metrics, proportions, weights and design. 
PT Serif consists of six styles: regular and bold weights with corresponding italics 
form a standard computer font family for basic text setting; 
two caption styles (regular and italic) are for texts of small point sizes.


[*](http://www.paratype.com/public/)


AUTHOR
======
PT Sans and PT Serif were designed by Alexandra Korolkova with 
participation of Olga Umpeleva and under supervision of Vladimir Yefimov.


LICENSE
=======
[ParaType Free Font Licensing Agreement](http://www.paratype.com/public/pt_openlicense_eng.asp)


FONT STYLES
===========
pt-serif_regular    
pt-serif_italic    
pt-serif_bold    
pt-serif_bold-italic    
   pt-serif_caption    
   pt-serif_caption-italic    


UI CONFIGURATION
================
AUTHOR
AKKORDEON
DOWNLOAD
FLOWTEXT
GENERALINFORMATION
LICENSE


FONTAIN HOWTO
=============


TEX HOWTO
=========

- Unzip pt-serif.tex.zip

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
  pt-serif.texmf.zip to your TEXMFHOME directory
  (copy over existing folders)

- Add the line `Map psr.map`
  to the file $TEXMFHOME/web2c/updmap.cfg
  (If the file/directory does not exist create it!)

- Update your TeX installation
 `updmap`

- Compile the testpage example_pt-serif.tex    
 `pdflatex example_pt-serif.tex`

### Future

- [Get started with LaTeX](http://en.wikibooks.org/wiki/LaTeX)
- Use `\fontfamily{psr}\selectfont` to select Paratype Serif
  during a LaTeX document
- Start to love LaTeX!




TEX CONFIGURATION
=================
KARLBERRYNAME:psr
FOUNDRY:paratype
TEXSRCREGULAR:pt-serif_regular
TEXSRCITALIC:pt-serif_italic
TEXSRCBOLD:pt-serif_bold    
TEXSRCBOLD-ITALIC:pt-serif_bold-italic

