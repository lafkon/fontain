#!/bin/bash

#.---------------------------------------------------------------------.#
#.                                                                      #
#. Copyright (C) 2014 LAFKON                                            #
#.                                                                      #
#. CREATE TTF,OTF,SVG,WOFF,TEX TREE FROM FONTFORGE SOURCES              #
#.                                                                      #
#. mk_fonts.sh is free software: you can redistribute it and/or modify  #
#. it under the terms of the GNU General Public License as published    #
#. by the Free Software Foundation, either version 3 of the License,    #
#. or (at your option) any later version.                               #
#.                                                                      #
#. mk_fonts.sh is distributed in the hope that it will be useful,       #
#. but WITHOUT ANY WARRANTY; without even the implied warranty of       #
#. MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                 #
#. See the GNU General Public License for more details.                 #
#.                                                                      #
#.---------------------------------------------------------------------.#


# PATH TO FONT DIRECTORY (TOP LEVEL)
# --------------------------------------------------------------------- #
  FONTS=`ls -d -1 fonts/*`
# FONTS=`ls -d -1 fonts/* | shuf -n 5`
# FONTS=`ls -d -1 fonts/* | head -n 1`


# SET VARIABLES
# --------------------------------------------------------------------- #
  TMPDIR=/tmp
  FONTCONVERT=lib/tools/tinytypetools/fontconvert/fontconvert
  TTF2EOT=lib/tools/ttf2eot/ttf2eot
  READMENAME=README.md
  LICENSENAME=LICENSE.txt

# ONLY RUN IF FONTCONVERT UTILITY EXISTS 
# --------------------------------------------------------------------- #
  if [ ! -f $FONTCONVERT ]; then exit 0; fi

# ===================================================================== #
# START THE EXPORT
# ===================================================================== #

  for FONTROOT in $FONTS
   do

    # SET VARIABLES 
    # ----------------------------------------------------------- #
      EXPORTROOT=$FONTROOT/export
      FONTNAME=`basename $FONTROOT`

    # MAKE TMPDIR; WILL BE DELETED AT THE END
    # ----------------------------------------------------------- #
      TMP=$TMPDIR/`echo $RANDOM | md5sum | cut -c 1-8`${RANDOM}X
    # TMP=$TMPDIR/nodelete
      mkdir $TMP

      for SRC in `find $FONTROOT -type d -name "*.sfdir"`
       do
          SRCROOT=`echo $SRC | rev | cut -d "/" -f 2- | rev`
          BASENAME=`basename $SRC | \
                    rev | cut -d "." -f 2- | rev`
   
        # EXPORT TTF,OTF,SVG,WOFF
        # ----------------------------------------------------- #

          for THIS in ttf otf svg woff
           do

            THISROOT=$EXPORTROOT/$THIS
            if [ ! -f $THISROOT ]; then mkdir -p $THISROOT ; fi
            if [ $SRC -nt $THISROOT/${BASENAME}.$THIS  ]; then

                 $FONTCONVERT --$THIS $SRC
                 mv $SRCROOT/*.$THIS $THISROOT
            else
               # echo "${BASENAME}.$THIS already up-to-date"
                 sleep 0
            fi

          done

        # EXPORT EOT
        # ----------------------------------------------------- #

          if [ -f $TTF2EOT ]; then

          EOTROOT=$EXPORTROOT/eot
          if [ ! -f $EOTROOT ]; then mkdir -p $EOTROOT ; fi
          if [ $SRC -nt $EOTROOT/${BASENAME}.eot  ]; then

               $FONTCONVERT --eot $SRC
               mv $SRCROOT/*.eot $EOTROOT
           else
             # echo "${BASENAME}.eot already up-to-date"
               sleep 0
           fi

          else
              echo "please compile ttf2eot (lib/tools/ttf2eot/)"
          fi

        # EXPORT UFO
        # ----------------------------------------------------- #

          UFOROOT=$EXPORTROOT/ufo
          if [ ! -f $UFOROOT ]; then mkdir -p $UFOROOT ; fi

          ZIPNAME=`echo $SRC | \
                   rev | cut -d "/" -f 1 | rev | \
                   cut -d "." -f 1`
          if [ $SRC -nt $UFOROOT/${BASENAME}.ufo.zip  ]; then

               $FONTCONVERT --ufo $SRC
               cd $SRCROOT
               cp ../$READMENAME .
               cp ../$LICENSENAME .
               zip -r ${ZIPNAME}.ufo.zip *.ufo $READMENAME $LICENSENAME
               rm $READMENAME $LICENSENAME
               cd -
               mv $SRCROOT/${ZIPNAME}.ufo.zip $UFOROOT
               rm -r $SRCROOT/*.ufo
          else
             # echo "${ZIPNAME}.ufo.zip already up-to-date"
               sleep 0
          fi

      done


    # CHECK CONFIGURATION 
    # ----------------------------------------------------------- #
      README=$FONTROOT/$READMENAME
      KBS=`grep KARLBERRYNAME $README | head -1 | cut -d ":" -f 2`






      if [ `echo $KBS | wc -c` -gt 1 ]; then 

      echo "tex configuration for $FONTROOT exists"

     # PREPARE FONT/STRUCTURE FOR USE WITH LATEX
     # =========================================================== #
       TEXMFROOT=$EXPORTROOT/tex
       if [ $SRC -nt $TEXMFROOT/${FONTNAME}.texmf.zip ]; then
       if [ ! -f $TEXMFROOT ]; then mkdir -p $TEXMFROOT ; fi
 
     # CREATE POSTSCRIPT TYPE1 SOURCES
     # ----------------------------------------------------------- #
       mkdir $TMP/ps1src
 
       for CUT in `grep TEXSRCREGULAR      $README | head -1`:r \
                  `grep TEXSRCITALIC       $README | head -1`:ri \
                  `grep TEXSRCBOLD         $README | head -1`:b \
                  `grep TEXSRCBOLD-ITALIC  $README | head -1`:bi
        do
 
        if [ `echo $CUT | cut -d ":" -f 2 | wc -c` -gt 4 ]; then
 
         CUTSRC=`echo $CUT | cut -d ":" -f 2`
         KBSCUT=`echo $CUT | cut -d ":" -f 3`
 
         SRC=`find $FONTROOT -name "${CUTSRC}.sfdir"`
         SRCROOT=`echo $SRC | rev | cut -d "/" -f 2- | rev`
 
       # SAFETY CHECK
         if [ `echo $SRCROOT | wc -c` -gt 4 ]; then       
 
         $FONTCONVERT --pstype1 $SRC
         mv $SRCROOT/*.pfb $TMP/ps1src/${KBS}${KBSCUT}8a.pfb
         mv $SRCROOT/*.afm $TMP/ps1src/${KBS}${KBSCUT}8a.afm
 
         fi
 
        fi
 
      done
 
     # SET TEXMF VARIABLES
     # ----------------------------------------------------------- #
     
       KBFNAME=$KBS
       FOUNDRYNAME=`grep FOUNDRY $README | head -1 | cut -d ":" -f 2`
       if [ `echo $FOUNDRYNAME | wc -c` -lt 2 ]; then
       FOUNDRYNAME=XXX
       fi
       LICENSE=$PWD/$FONTROOT/LICENSE.txt    
       README=$PWD/$FONTROOT/$READMENAME
       PSTYPE1DIR="$TMP/ps1src"
 
       TEXMF=$TMP/TEXMF
       mkdir $TEXMF
     
       DRV="$KBFNAME-drv.tex"
       MAP="$KBFNAME-map.tex"
    
       cp ${PSTYPE1DIR}/${KBFNAME}* $TMP
 
     # CREATE TEXMF STRUCTURE
     # ----------------------------------------------------------- #
 
       cd $TMP
     
       echo "% $DRV"                              >  $DRV
       echo "\input fontinst.sty"                 >> $DRV
       echo "\recordtransforms{$KBFNAME-rec.tex}" >> $DRV
       echo "\latinfamily{$KBFNAME}{}"            >> $DRV
       echo "\endrecordtransforms"                >> $DRV
       echo "\bye"                                >> $DRV
     
       tex $DRV
     
       for F in *.pl;  do pltotf $F; done
       for F in *.vpl; do vptovf $F; done
         
       mkdir -p $TEXMF/fonts/afm/$FOUNDRYNAME/$FONTNAME
       mkdir -p $TEXMF/fonts/tfm/$FOUNDRYNAME/$FONTNAME
       mkdir -p $TEXMF/fonts/type1/$FOUNDRYNAME/$FONTNAME
       mkdir -p $TEXMF/fonts/vf/$FOUNDRYNAME/$FONTNAME    
       mkdir -p $TEXMF/tex/latex/$FOUNDRYNAME/$FONTNAME
     
       mv *.afm $TEXMF/fonts/afm/$FOUNDRYNAME/$FONTNAME/
       cp $LICENSE $TEXMF/fonts/afm/$FOUNDRYNAME/$FONTNAME/
       mv *.tfm $TEXMF/fonts/tfm/$FOUNDRYNAME/$FONTNAME/
       cp $LICENSE $TEXMF/fonts/tfm/$FOUNDRYNAME/$FONTNAME/
       mv *.vf $TEXMF/fonts/vf/$FOUNDRYNAME/$FONTNAME/
       cp $LICENSE $TEXMF/fonts/vf/$FOUNDRYNAME/$FONTNAME/
       mv *.pfb $TEXMF/fonts/type1/$FOUNDRYNAME/$FONTNAME/
       cp $LICENSE $TEXMF/fonts/type1/$FOUNDRYNAME/$FONTNAME/
       mv *.fd $TEXMF/tex/latex/$FOUNDRYNAME/$FONTNAME/
       cp $LICENSE $TEXMF/tex/latex/$FOUNDRYNAME/$FONTNAME/
     
       echo "\input finstmsc.sty"                 >  $MAP
       echo "\resetstr{PSfontsuffix}{.pfb}"       >> $MAP
       echo "\adddriver{dvips}{$KBFNAME.map}"     >> $MAP
       echo "\input $KBFNAME-rec.tex"             >> $MAP
       echo "\donedrivers"                        >> $MAP
       echo "\bye"                                >> $MAP
     
       tex $MAP
     
       mkdir -p $TEXMF/dvips/config/
       mkdir -p $TEXMF/fonts/map/dvips/
       mkdir -p $TEXMF/web2c/
  
       cp $KBFNAME.map $TEXMF/dvips/config/
       cp $KBFNAME.map $TEXMF/fonts/map/dvips/
     
       rm *.vpl *.pl *.tex *.mtx *.map # *.log
 
       FONTTEST=example_${FONTNAME}.tex
 
       echo '\documentclass{article}'                           >  $FONTTEST
       echo '\parindent=0pt'                                    >> $FONTTEST
       echo '\pagestyle{empty}'                                 >> $FONTTEST
       echo '\setlength{\textheight}{.85\paperheight}'          >> $FONTTEST
       echo '\setlength{\topmargin}{-.07\textheight}'           >> $FONTTEST
       echo '\newcommand{\testblock}[1]{'                       >> $FONTTEST
       echo "{\fontfamily{$KBFNAME}\selectfont#1%"              >> $FONTTEST
       echo "Lorem ipsum dolor sit amet, consectetur             
             adipisicing elit, sed do eiusmod tempor incididunt  
             ut labore et dolore magna aliqua. \textit{Ut enim    
             ad minim veniam, quis nostrud exercitation ullamco   
             laboris nisi ut aliquip ex ea commodo consequat.    
             Duis aute irure dolor in reprehenderit in voluptate 
             velit esse cillum dolore eu fugiat} nulla pariatur.  
             \textbf{Excepteur sint occaecat cupidatat non       
             proident, sunt in culpa qui officia deserunt        
             mollit anim id est laborum.}" | \
             tr -s ' ' | fold -s -w 60 | sed -e 's/^[ \t]*//'   >> $FONTTEST
       echo '\newline'                                          >> $FONTTEST
       echo 'fi ff fj ffi ffl fa fe fo fr fs ft fb fh fu fy f.' >> $FONTTEST
       echo ''                                                  >> $FONTTEST
       echo '\vfill'                                            >> $FONTTEST
       echo '}}'                                                >> $FONTTEST
       echo '\begin{document}'                                  >> $FONTTEST
       echo "\testblock{\tiny}"                                 >> $FONTTEST
       echo "\testblock{\scriptsize}"                           >> $FONTTEST
       echo "\testblock{\footnotesize}"                         >> $FONTTEST
       echo "\testblock{\small}"                                >> $FONTTEST
       echo "\testblock{\normalsize}"                           >> $FONTTEST
       echo "\testblock{\large}"                                >> $FONTTEST
       echo "\testblock{\Large}"                                >> $FONTTEST
       echo "\testblock{\LARGE}"                                >> $FONTTEST
       echo "\testblock{\huge}"                                 >> $FONTTEST
       echo "\testblock{\Huge}"                                 >> $FONTTEST
       echo '\end{document}'                                    >> $FONTTEST
 
     # zip -r ${FONTNAME}.texmf.zip TEXMF README.txt $FONTTEST
       zip -r ${FONTNAME}.texmf.zip TEXMF
 
       cd -
 
       mv $TMP/${FONTNAME}.texmf.zip $TEXMFROOT
       mv $TMP/$FONTTEST             $TEXMFROOT

       else
       echo "tex files for $FONTROOT up-to-date"

       fi 
      else

       echo "make no tex files for $FONTROOT"
 
       fi


       if [ -d $TMP ]; then rm -r $TMP ; fi

  done

exit 0;


