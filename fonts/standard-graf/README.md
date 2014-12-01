STANDARD-GRAF
=============
CLASSIFICATION: Blackletter


GENERAL INFORMATION
===================
TODO


AUTHOR
======
[Peter Wiegel](http://www.peter-wiegel.de/)


LICENSE
=======
[General Public License (GPL) with font exception](http://www.fsf.org/licenses/gpl.html) **AND**
[SIL Open Font License (OFL)](http://scripts.sil.org/OFL)



FONTAIN HOWTO
=============




TEX HOWTO
=========

- Unzip standard-graf.tex.zip

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
  standard-graf.texmf.zip to your TEXMFHOME directory
  (copy over existing folders)

- Add the line `Map psg.map`
  to the file $TEXMFHOME/web2c/updmap.cfg
  (If the file/directory does not exist create it!)

- Update your TeX installation
 `updmap`

- Compile the testpage example_standard-graf.tex    
 `pdflatex example_standard-graf.tex`

### Future

- [Get started with LaTeX](http://en.wikibooks.org/wiki/LaTeX)
- Use `\fontfamily{psg}\selectfont` to select Standard Graf
  during a LaTeX document
- Start to love LaTeX!


TEX CONFIGURATION
=================
KARLBERRYNAME:psg
FOUNDRY:peterwiegel
TEXSRCREGULAR:standard-graf_regular

