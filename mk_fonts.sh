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

    # echo $FONTROOT

    # MAKE TMPDIR; WILL BE DELETED AGAIN
    # ----------------------------------------------------------- #
      TMP=$TMPDIR/`echo $RANDOM | md5sum | cut -c 1-8`${RANDOM}X
      mkdir $TMP

    # SET VARIABLES 
    # ----------------------------------------------------------- #
      NAME=`basename $FONTROOT`
      EXPORTROOT=$FONTROOT/export



    # ONLY RUN IF FONTCONVERT UTILITY EXISTS 
    # ----------------------------------------------------------- #


      if [ -f $FONTCONVERT ]; then


      for SRC in `find $FONTROOT -type d -name "*.sfdir"`
       do
          SRCROOT=`echo $SRC | rev | cut -d "/" -f 2- | rev`

        # EXPORT TTF
        # ----------------------------------------------------------- #
          TTFROOT=$EXPORTROOT/ttf   
          if [ ! -f $TTFROOT ]; then mkdir -p $TTFROOT ; fi
        # if [ $SRC -nt `ls -t $TTFROOT/*.ttf | head -1` ]; then
          if [ `find $TTFROOT -newer $SRC -name "*.ttf" | \
                wc -l` -lt 1 ]; then

               $FONTCONVERT --ttf $SRC
               mv $SRCROOT/*.ttf $TTFROOT
          else
               echo "$TTFROOT already up-to-date"
          fi
       
        # EXPORT OTF
        # ----------------------------------------------------------- #
          OTFROOT=$EXPORTROOT/otf   
          if [ ! -f $OTFROOT ]; then mkdir -p $OTFROOT ; fi
        # if [ $SRC -nt `ls -t $OTFROOT/*.otf | head -1` ]; then
          if [ `find $OTFROOT -newer $SRC -name "*.otf" | \
                wc -l` -lt 1 ]; then

               $FONTCONVERT --otf $SRC
               mv $SRCROOT/*.otf $OTFROOT
          else
               echo "$OTFROOT already up-to-date"
          fi
 
        # EXPORT SVG
        # ----------------------------------------------------------- #
          SVGROOT=$EXPORTROOT/svg
          if [ ! -f $SVGROOT ]; then mkdir -p $SVGROOT ; fi
        # if [ $SRC -nt `ls -t $SVGROOT/*.svg | head -1` ]; then
          if [ `find $SVGROOT -newer $SRC -name "*.svg" | \
                wc -l` -lt 1 ]; then

               $FONTCONVERT --svg $SRC
               mv $SRCROOT/*.svg $SVGROOT
          else
               echo "$SVGROOT already up-to-date"
          fi
  
        # EXPORT WOFF
        # ----------------------------------------------------------- #
          WOFFROOT=$EXPORTROOT/woff
          if [ ! -f $WOFFROOT ]; then mkdir -p $WOFFROOT ; fi
        # if [ $SRC -nt `ls -t $WOFFROOT/*.woff | head -1` ]; then
          if [ `find $WOFFROOT -newer $SRC -name "*.woff" | \
                wc -l` -lt 1 ]; then

               $FONTCONVERT --woff $SRC
               mv $SRCROOT/*.woff $WOFFROOT
          else
               echo "$WOFFROOT already up-to-date"
          fi
   
        # EXPORT EOT
        # ----------------------------------------------------------- #

          if [ -f $FONTCONVERT ]; then

          EOTROOT=$EXPORTROOT/eot
          if [ ! -f $EOTROOT ]; then mkdir -p $EOTROOT ; fi
        # if [ $SRC -nt `ls -t $EOTROOT/*.eot | head -1` ]; then
          if [ `find $EOTROOT -newer $SRC -name "*.eot" | wc -l` -lt 1 ]; then

               $FONTCONVERT --eot $SRC
               mv $SRCROOT/*.eot $EOTROOT
           else
               echo "$EOTROOT already up-to-date"
           fi

          else

              echo "please compile ttf2eot (lib/tools/ttf2eot/)"
          fi

        # EXPORT UFO
        # ----------------------------------------------------------- #
          UFOROOT=$EXPORTROOT/ufo
          if [ ! -f $UFOROOT ]; then mkdir -p $UFOROOT ; fi
        # if [ $SRC -nt `ls -t $UFOROOT | head -1` ]; then
          if [ `find $UFOROOT -newer $SRC -name "*.zip" | \
                wc -l` -lt 1 ]; then

               $FONTCONVERT --ufo $SRC
               ZIPNAME=`echo $SRC | \
                        rev | cut -d "/" -f 1 | rev | \
                        cut -d "." -f 1`
               cd $SRCROOT
               zip -r ${ZIPNAME}.ufo.zip *.ufo 
               cd -
               mv $SRCROOT/${ZIPNAME}.ufo.zip $UFOROOT
               rm -r $SRCROOT/*.ufo
          else
               echo "$UFOROOT already up-to-date"
          fi


      done




      else

      echo "$FONTCONVERT missing -> Stopping!"

      fi




    # PREPARE FONT/STRUCTURE FOR USE WITH LATEX
    # ----------------------------------------------------------- #
    # CHECK CONFIGURATION 
    # ----------------------------------------------------------- #
      README=$FONTROOT/$READMENAME


      if [ -f $README ]; then

         sleep 0

      fi



      rm -r $TMP

  done
















exit 0;


