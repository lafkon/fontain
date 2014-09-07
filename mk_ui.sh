#!/bin/bash

# PATH TO FONT DIRECTORY (TOP LEVEL)
# ----------------------------------------------------------------- #
  FONTS=`ls -d -1 fonts/*`

  WWWDIR=~/tmp/fontain


# TEMPLATES
# ----------------------------------------------------------------- #
  TMPLT_CSS=lib/ui/templates/css.template
  TMPLT_HEAD=lib/ui/templates/head.template
  TMPLT_FOOT=lib/ui/templates/foot.template
  TMPLT_AKKORDION=lib/ui/templates/akkordeon.template
  TMPLT_AKKRDNSLIDER=lib/ui/templates/akkordeon_slider.template
  TMPLT_DOWNLOAD=lib/ui/templates/download.template

# COPY STATIC STUFF 
# ----------------------------------------------------------------- #
  cp -r `ls -d lib/ui/* | egrep -v "parts"` $WWWDIR

# LICENSE/READMENAMES (MD OR TXT?)
# ----------------------------------------------------------------- #
  READMENAME=README.txt
  LICENSENAME=LICENSE.txt



# ================================================================= #
# CREATE WWW USER INTERFACE
# ================================================================= #

  for FONTFAMILY in $FONTS
   do
      FAMILYNAME=`grep -h "FamilyName" $FONTFAMILY/src/*/font.props | \
                   cut -d ":" -f 2 | \
                   awk '{print length, $0;}' | sort -n | \
                   head -n 1 | cut -d " " -f 2- | \
                   sed "s/^[ \t]*//"`
    # FAMILYNAMEWWW=`echo $FAMILYNAME | sed 's/ //g'`
      FAMILYNAMEWWW=`echo $FAMILYNAME | \
                     sed 's/ /jfdDw24e/g' | \
                     sed 's/[^a-zA-Z0-9 ]//g' | \
                     sed 's/jfdDw24e/-/g' | \
                     tr [:upper:] [:lower:]`

      SPECIMENSRC=$FONTFAMILY/specimen

      FAMILYTARGET=$WWWDIR/`basename $FONTFAMILY`
      WEBFONTTARGET=$FAMILYTARGET/webfont
      SPECIMENTARGET=$FAMILYTARGET/specimen
      EXPORTTARGET=$FAMILYTARGET/export

      CSS=$WEBFONTTARGET/webfont.css
      INDEX=$FAMILYTARGET/index.html


      mkdir -p $FAMILYTARGET
      mkdir -p $WEBFONTTARGET
      mkdir -p $SPECIMENTARGET
      mkdir -p $EXPORTTARGET
      if [ -f $CSS ]; then rm $CSS ; fi


   # =========================================================== #
   # CREATE HTML FILE
   # =========================================================== #
     cat $TMPLT_HEAD                                   >  $INDEX

   # ----------------------------------------------------------- #
     echo '<div class="sixteen columns accordion" \
            id="sortable">' | tr -s ' '                >> $INDEX

   # USE CUSTOM ORDER IF AVAILABLE
   # ----------------------------------------------------------- #
     if [ -f $FONTFAMILY/specimen/selection.list ]; then

         SELECTION=
         for FONTSTYLE in `cat $FONTFAMILY/specimen/selection.list`
          do
             FONTSTYLE=`basename $FONTSTYLE | cut -d "." -f 1`
             SELECTION="$SELECTION "`find $FONTFAMILY/src/ \
                                          -name "${FONTSTYLE}.sfdir"`
         done
         SELECTION=`echo $SELECTION | # 
                    sed 's/ /\n /g' | # SPACES TO LINEBREAK 
                    awk ' !x[$0]++'`  # REMOVE IDENTICAL LINES

     else
         SELECTION=`ls -d -1 $FONTFAMILY/src/*.sfdir`
     fi

   # ----------------------------------------------------------- #
   # AKKORDEON LOOP FOR FONTSTYLES
   # ----------------------------------------------------------- #
     COUNT=1
     for FONTSTYLE in $SELECTION
      do
          STYLENAME=`grep -h "FullName" $FONTSTYLE/font.props | \
                      cut -d ":" -f 2 | sed "s/^[ \t]*//"`
        # STYLENAMEWWW=`echo $STYLENAME | sed 's/ /_/g'`
          STYLENAMEWWW=`echo $STYLENAME | \
                        sed 's/ /jfdDw24e/g' | \
                        sed 's/[^a-zA-Z0-9 ]//g' | \
                        sed 's/jfdDw24e/-/g' | \
                        tr [:upper:] [:lower:]`

          FONTSTYLESRC=`basename $FONTSTYLE | sed "s/.sfdir//g"` 


          EOTFILE=`find $FONTFAMILY -name "${FONTSTYLESRC}.eot"`
          cp -p $EOTFILE $WEBFONTTARGET
          EOTFILE=`basename $EOTFILE`

          WOFFFILE=`find $FONTFAMILY -name "${FONTSTYLESRC}.woff"`
          cp -p $WOFFFILE $WEBFONTTARGET
          WOFFFILE=`basename $WOFFFILE`

          SVGFILE=`find $FONTFAMILY -name "${FONTSTYLESRC}.svg"`
          cp -p $SVGFILE $WEBFONTTARGET
          SVGFILE=`basename $SVGFILE`

          TTFFILE=`find $FONTFAMILY -name "${FONTSTYLESRC}.ttf"`
          cp -p $TTFFILE $WEBFONTTARGET
          TTFFILE=`basename $TTFFILE`


          cat $TMPLT_CSS | \
          sed "s/EOTFILE/$EOTFILE/g" | \
          sed "s/SVGFILE/$SVGFILE/g" | \
          sed "s/TTFFILE/$TTFFILE/g" | \
          sed "s/WOFFFILE/$WOFFFILE/g" | \
          sed "s/FONTFAMILY/$STYLENAMEWWW/g" >> $CSS
          echo                               >> $CSS

          cat $TMPLT_AKKORDION | \
          sed "s/STYLENAMEWWW/$STYLENAMEWWW/g" | \
          sed "s/STYLENAME/$STYLENAME/g" | \
          sed "s/-COUNT/-$COUNT/g" | \
          sed "s/FAMILYNAME/$FAMILYNAME/g"  >> $INDEX

          COUNT=`expr $COUNT + 1`

     done
   # ----------------------------------------------------------- #
     echo '</div>'                                     >> $INDEX
     cat $TMPLT_AKKRDNSLIDER                           >> $INDEX
   # ----------------------------------------------------------- #
     cat $TMPLT_DOWNLOAD                               >> $INDEX
   # ----------------------------------------------------------- #
     if [ -f $SPECIMENSRC/info.md ]; then

      echo '<div class="fourteen columns">'            >> $INDEX
      cat $SPECIMENSRC/info.md | \
      pandoc -r markdown -w html                       >> $INDEX
      echo '</div>'                                    >> $INDEX

     fi
   # ----------------------------------------------------------- #
     if [ -f $SPECIMENSRC/*.svg ]; then
      for SVGSRC in `ls $SPECIMENSRC/*.svg`
       do
          SVGTARGET=$SPECIMENTARGET/`basename $SVGSRC | \
                                     rev | \
                                     cut -d "." -f 2- | rev`.png
          inkscape --export-png=$SVGTARGET \
                   $SVGSRC > /dev/null
      done
     fi
   # ----------------------------------------------------------- #
     if [ -f $SPECIMENSRC/*.png ]; then
          cp $SPECIMENSRC/*.png $SPECIMENTARGET
     fi
   # ----------------------------------------------------------- #
     if [ -f $SPECIMENTARGET/*.png ]; then
      for PNG in `ls $SPECIMENTARGET/*.png`
       do
          PNG=`echo $PNG | rev | cut -d "/" -f 1-2 | rev`
          echo "<img class=\"sixteen columns specipic\" \
                 src=\"$PNG\" />" | tr -s ' '          >> $INDEX
      done
     fi
   # ----------------------------------------------------------- #
     cat $TMPLT_FOOT                                   >> $INDEX


   # =========================================================== #
   # CREATE DOWNLOADS
   # =========================================================== #
     ZIPNAME=$FAMILYNAMEWWW

   # ----------------------------------------------------------- #
   # CREATE DIRECTORIES
   # ----------------------------------------------------------- #
     for EXPORT in ttf otf ufo webfont tex 
      do
         mkdir -p $EXPORTTARGET/$EXPORT
     done

   # ----------------------------------------------------------- #
   # ZIP WEBFONT DIRECTORY (IF THERE EXISTS A NEWER SOURCE)
   # ----------------------------------------------------------- #
     NEWESTFILE=`find $FONTFAMILY -type f -printf '%T@ %p\n' | \
                 egrep ".ttf|.eot|.woff|.svg" | \
                 sort -n | tail -1 | cut -f 2- -d " "`

     if [ `find $EXPORTTARGET/webfont/  -name "*.zip" \
           -newer $NEWESTFILE | wc -l` -gt 0 ]
     then

       echo "${ZIPNAME}.webfont.zip is up-to-date"

     else

       if [ -f $FONTFAMILY/$READMENAME ]; then
       cp $FONTFAMILY/$READMENAME  $WEBFONTTARGET ; fi
       if [ -f $FONTFAMILY/$LICENSENAME ]; then
       cp $FONTFAMILY/$LICENSENAME $WEBFONTTARGET ; fi
  
       cd $WEBFONTTARGET
  
          zip -r ${ZIPNAME}.webfont.zip *.*
  
          if [ -f $READMENAME ];  then rm $READMENAME  ; fi
          if [ -f $LICENSENAME ]; then rm $LICENSENAME ; fi

        # touch -r `ls -tr *.* | egrep -v ".zip|.css" | \
        #           tail -n 1` \
        #       ${ZIPNAME}.webfont.zip

       cd - > /dev/null

   # MOVE ZIP TO LOCATION
   # ----------------------------------------------------------- #
       mv $WEBFONTTARGET/${ZIPNAME}.webfont.zip $EXPORTTARGET/webfont

     fi

       ZIPLINKFOO=WWWZIP
       sed -i "s,$ZIPLINKFOO,export/webfont/${ZIPNAME}.webfont.zip,g" $INDEX



   # ----------------------------------------------------------- #
   # ZIP THE REST (IF THERE EXISTS A NEWER SOURCE)
   # ----------------------------------------------------------- #
     for FORMAT in ttf otf ufo
      do
         NEWESTFILE=`find $FONTFAMILY/export/$FORMAT  \
                          -type f -printf '%T@ %p\n' | \
                     sort -n | tail -1 | cut -f 2- -d " "`

        ZIPTARGET=${ZIPNAME}.$FORMAT.zip

        if [ `find $EXPORTTARGET/$FORMAT/ -name "*.zip" \
              -newer $NEWESTFILE | wc -l` -gt 0 ]
        then

           echo "$ZIPTARGET is up-to-date"

        else

           cd $FONTFAMILY/export/$FORMAT

           if [ -f ../../$READMENAME ]; then
           cp ../../$READMENAME . ; fi
           if [ -f ../../$LICENSENAME ]; then
           cp ../../$LICENSENAME . ; fi

           zip -r X-${ZIPNAME}.$FORMAT.zip *.*

           if [ -f $READMENAME ];  then rm $READMENAME  ; fi
           if [ -f $LICENSENAME ]; then rm $LICENSENAME ; fi

           cd - > /dev/null

   # MOVE ZIP TO LOCATION
   # ----------------------------------------------------------- #
           mv $FONTFAMILY/export/$FORMAT/X-${ZIPNAME}.$FORMAT.zip \
              $EXPORTTARGET/$FORMAT/${ZIPNAME}.$FORMAT.zip
        fi

        ZIPLINKFOO=`echo $FORMAT | tr [:lower:] [:upper:]`ZIP
        sed -i "s,$ZIPLINKFOO,export/$FORMAT/${ZIPNAME}.$FORMAT.zip,g" $INDEX


     done
   # =========================================================== #

     sed -i "s/FONTFAMILY/$FAMILYNAME/g"                  $INDEX



  done



exit 0;

