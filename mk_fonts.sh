#!/bin/bash



# PATH TO FONT DIRECTORY (TOP LEVEL)
# ----------------------------------------------------------------- #
  FONTS=`ls -d -1 fonts/*`
# FONTS=`ls -d -1 fonts/* | shuf -n 5`
# FONTS=`ls -d -1 fonts/* | head -n 5`


# SET VARIABLES
# ----------------------------------------------------------------- #
  TMPDIR=/tmp
  FONTCONVERT=lib/tools/tinytypetools/fontconvert/fontconvert
  TTF2EOT=lib/tools/ttf2eot/ttf2eot
  READMENAME=README.txt


# START THE EXPORT
# ----------------------------------------------------------------- #
  for FONTROOT in $FONTS
   do

    # SET VARIABLES 
    # ----------------------------------------------------------- #
    # NAME=`basename $FONTROOT`
      EXPORTROOT=$FONTROOT/export



    # ONLY RUN IF FONTCONVERT UTILITY EXISTS 
    # ----------------------------------------------------------- #
      if [ ! -f $FONTCONVERT ]; then exit 0; fi


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
                 echo "${BASENAME}.$THIS already up-to-date"
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
               echo "${BASENAME}.eot already up-to-date"
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
               echo "${ZIPNAME}.ufo.zip already up-to-date"
          fi

      done




#   # MAKE TMPDIR; WILL BE DELETED AGAIN
#   # ----------------------------------------------------------- #
#     TMP=$TMPDIR/`echo $RANDOM | md5sum | cut -c 1-8`${RANDOM}X
#     TMP=$TMPDIR/nodelete
#     mkdir $TMP


#   # PREPARE FONT/STRUCTURE FOR USE WITH LATEX
#   # ----------------------------------------------------------- #

#   # CHECK CONFIGURATION 
#   # ----------------------------------------------------------- #
#     README=$FONTROOT/$READMENAME

#     KBS=`grep KARLBERRY $README | head -1 | cut -d ":" -f 2`


#     mkdir $TMP/ps1src

#     for CUT in `grep REGULAR      $README | head -1`:r \
#                `grep ITALIC       $README | head -1`:ri \
#                `grep BOLD         $README | head -1`:b \
#                `grep BOLD-ITALIC  $README | head -1`:bi
#      do


#      if [ `echo $CUT | cut -d ":" -f 2 | wc -c` -gt 1 ]; then

#       CUTSRC=`echo $CUT | cut -d ":" -f 2`
#       KBSCUT=`echo $CUT | cut -d ":" -f 3`

#       SRC=`find $FONTROOT -name "$CUTSRC"`
#       SRCROOT=`echo $SRC | rev | cut -d "/" -f 2- | rev`

#       $FONTCONVERT --pstype1 $SRC
#       mv $SRCROOT/*.pfb $TMP/ps1src/${KBS}${KBSCUT}8a.pfb
#       mv $SRCROOT/*.afm $TMP/ps1src/${KBS}${KBSCUT}8a.afm

#      fi





#     done
















#      rm -r $TMP

  done
















exit 0;


