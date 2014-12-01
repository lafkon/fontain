RALEWAY
=======
CLASSIFICATION: Sans-Serif


GENERAL INFORMATION
===================
> Raleway is an elegant sans-serif typeface, designed in a single thin weight. 
> It is a display face that features both old style and lining numerals, 
> standard and discretionary ligatures, a pretty complete set of diacritics, 
> as well as a stylistic alternate inspired by more geometric sans-serif 
> typefaces than it's neo-grotesque inspired default character set.
> [*](https://www.theleagueofmoveabletype.com/raleway)


AUTHOR
======
[Matt McInerney](http://pixelspread.com/)


LICENSE
=======
[SIL Open Font License (OFL)](http://scripts.sil.org/OFL)


FONTAIN HOWTO
=============



TEX HOWTO
=========

- Unzip raleway.tex.zip

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
  raleway.zip to your TEXMFHOME directory
  (copy over existing folders)

- Add the line `Map lra.map`
  to the file $TEXMFHOME/web2c/updmap.cfg
  (If the file/directory does not exist create it!)

- Update your TeX installation
 `updmap`

- Compile the testpage example_raleway.tex    
 `pdflatex example_raleway.tex`

### Future

- [Get started with LaTeX](http://en.wikibooks.org/wiki/LaTeX)
- Use `\fontfamily{lra}\selectfont` to select Raleway
  during a LaTeX document
- Start to love LaTeX!




TEX CONFIGURATION
=================
KARLBERRYNAME:lra
FOUNDRY:theleague
TEXSRCREGULAR:raleway_thin





