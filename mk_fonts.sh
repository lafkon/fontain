#!/bin/bash



# PATH TO FONT DIRECTORY (TOP LEVEL)
# ----------------------------------------------------------------- #
  FONTS=`ls -d -1 fonts/*`
# FONTS=`ls -d -1 fonts/* | shuf -n 5`
# FONTS=`ls -d -1 fonts/* | head -n 1`

# SET VARIABLES
# ----------------------------------------------------------------- #
  TMPDIR=/tmp
  FONTCONVERT=lib/tools/tinytypetools/fontconvert/fontconvert
  TTF2EOT=lib/tools/ttf2eot/ttf2eot
  READMENAME=README.txt

# ONLY RUN IF FONTCONVERT UTILITY EXISTS 
# ----------------------------------------------------------------- #
  if [ ! -f $FONTCONVERT ]; then exit 0; fi




# ================================================================= #
# START THE EXPORT
# ================================================================= #

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
               zip -r ${ZIPNAME}.ufo.zip *.ufo 
               cd -
               mv $SRCROOT/${ZIPNAME}.ufo.zip $UFOROOT
               rm -r $SRCROOT/*.ufo
          else
             # echo "${ZIPNAME}.ufo.zip already up-to-date"
               sleep 0
          fi

      done



    # PREPARE FONT/STRUCTURE FOR USE WITH LATEX
    # =========================================================== #
      TEXMFROOT=$EXPORTROOT/texmf
      if [ ! -f $TEXMFROOT ]; then mkdir -p $TEXMFROOT ; fi

    # CHECK CONFIGURATION 
    # ----------------------------------------------------------- #
      README=$FONTROOT/$READMENAME
      KBS=`grep KARLBERRY $README | head -1 | cut -d ":" -f 2`


    # CREATE POSTSCRIPT TYPE1 SOURCES
    # ----------------------------------------------------------- #
      mkdir $TMP/ps1src

      for CUT in `grep REGULAR      $README | head -1`:r \
                 `grep ITALIC       $README | head -1`:ri \
                 `grep BOLD         $README | head -1`:b \
                 `grep BOLD-ITALIC  $README | head -1`:bi
       do

       if [ `echo $CUT | cut -d ":" -f 2 | wc -c` -gt 1 ]; then

        CUTSRC=`echo $CUT | cut -d ":" -f 2`
        KBSCUT=`echo $CUT | cut -d ":" -f 3`

        SRC=`find $FONTROOT -name "$CUTSRC"`
        SRCROOT=`echo $SRC | rev | cut -d "/" -f 2- | rev`

        $FONTCONVERT --pstype1 $SRC
        mv $SRCROOT/*.pfb $TMP/ps1src/${KBS}${KBSCUT}8a.pfb
        mv $SRCROOT/*.afm $TMP/ps1src/${KBS}${KBSCUT}8a.afm

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
    
      cp $KBFNAME.map $TEXMF/dvips/config/
      cp $KBFNAME.map $TEXMF/fonts/map/dvips/
    
      rm *.vpl *.pl *.tex *.mtx *.map # *.log


      echo "test" > README.txt


      zip -r ${FONTNAME}.texmf.zip TEXMF README.txt


      cd -

      mv $TMP/${FONTNAME}.texmf.zip $TEXMFROOT

   
#   # https://www.tug.org/fonts/fontinstall-personal.html
#   
#   # FIND ABOUT YOUR LOCAL TEXMF TREE
#   # kpsewhich --var-value=TEXMFHOME  
#   
#   # COPY TEXMF DIRECTORY TO YOUR LOCAL TEXMF TREE
#   
#   # ADD UPDMAP e.g.
#   # Map cfi.map >> .TEXMF/web2c/updmap.cfg
#   echo "Map ${KBFNAME}.map" >> $UPDMAP
#   
#   
#   # UPDATE TEX INSTALLATION
#   # updmap













      rm -r $TMP

  done
















exit 0;


