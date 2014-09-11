#!/bin/bash

# PATH TO FONT DIRECTORY (TOP LEVEL)
# ----------------------------------------------------------------- #
  FONTS=`ls -d -1 fonts/*`


  OUTPUTDIR=$1
# --------------------------------------------------------------------------- #
# INTERACTIVE CHECKS 
# --------------------------------------------------------------------------- #
  if [ -z "$OUTPUTDIR" ]; then

        echo
        echo "Where should the output go? Please provide an output directory:"
        echo "$0 PATH/TO/OUTPUTDIRECTORY"
        echo
        exit 0;
  fi

# STRIP TRAILING SLASH
  OUTPUTDIR=`echo $OUTPUTDIR | sed 's,/$,,g'`
# REMOVE 'FONTAIN' SUBDIRECTORY TO PLACE IT OURSELVES
  OUTPUTDIR=`echo $OUTPUTDIR | sed 's,/fontain$,,g'`
  OUTPUTDIR=$OUTPUTDIR/fontain

  if [ -d $OUTPUTDIR ]; then

       echo "$OUTPUTDIR exists"
       read -p "overwrite ${PDF}? [y/n] " ANSWER
       if [ $ANSWER = n ] ; then echo "Bye-bye"; exit 0; fi

  fi

  WWWDIR=$OUTPUTDIR
  echo "writing to $WWWDIR"; sleep 3 # SOME TIME TO CHANGE YOUR MIND

# TEMPLATES
# ----------------------------------------------------------------- #
  TMPLT_CSS=lib/ui/templates/css.template
  TMPLT_HEAD=lib/ui/templates/head.template
  TMPLT_FOOT=lib/ui/templates/foot.template
  TMPLT_AKKORDION=lib/ui/templates/akkordeon.template
  TMPLT_AKKRDNSLIDER=lib/ui/templates/akkordeon_slider.template
  TMPLT_DOWNLOAD=lib/ui/templates/download.template
  TMPLT_FLOWTEXT=lib/ui/templates/flowtext.template

# LICENSE/READMENAMES (MD OR TXT?)
# ----------------------------------------------------------------- #
  READMENAME=README.md
  LICENSENAME=LICENSE.txt


# LICENSE/READMENAMES (MD OR TXT?)
# ----------------------------------------------------------------- #
  TMPDIR=/tmp
  CSSCOLLECT=$TMPDIR/css.tmp

  NLPROTECT=L1N38R34K$RANDOM  # PLACEHOLDER TO PROTECT NEWLINES
  KUNDPROTECT=K4U7M4NN$RANDOM # PLACEHOLDER TO PROTECT &

# COPY STATIC STUFF 
# ----------------------------------------------------------------- #
  if [ ! -d $WWWDIR ]; then  mkdir -p $WWWDIR ; fi
  cp -r `ls -d lib/ui/* | egrep -v "templates"` $WWWDIR


# --------------------------------------------------------------------------- #
# FUNCTIONS
# --------------------------------------------------------------------------- #
  function cpifnewer() {
                          
      CPSRCPATH=`echo $1 | rev | cut -d "/" -f 2- | rev`
      CPSRCBASE=`basename $1`
      CPTARGETPATH=`echo $2 | rev | cut -d "/" -f 2- | rev`
      CPTARGETBASE=`basename $2`

      if [ -f $CPTARGETPATH/$CPTARGETBASE ]; then
       if [ `find $CPSRCPATH -name "$CPSRCBASE" \
			     -newer $CPTARGETPATH/$CPTARGETBASE | \
	    wc -l` -gt 0 ];then
	    echo "$CPSRCPATH/$CPSRCBASE has changed"
            cp -p $CPSRCPATH/$CPSRCBASE $CPTARGETPATH/$CPTARGETBASE
       else
            echo "$CPTARGETPATH/$CPTARGETBASE at latest state"
       fi
      else
            cp -p $CPSRCPATH/$CPSRCBASE $CPTARGETPATH/$CPTARGETBASE
      fi
  }

# --------------------------------------------------------------------------- #
  function AKKORDEON(){

    if [ -f $README ]; then
    FONTSTYLES=`sed '/^\s*$/d' $README    |  # REMOVE EMPTY LINES
                sed 's/^ .*/XX&/'         |  # REPLACE LEADING BLANK WITH XX
                sed 's/ //g'              |  # REMOVE SPACES (WORKAROUND!!!!)
                sed -e :a \
                -e '$!N;s/\n=====/=====/;ta' \
                -e 'P;D'                  |  # APPEND LINES WITH =====
                sed '/=====$/{x;p;x;}'    |  # INSERT EMPTY LINE ABOVE
                sed -e '/./{H;$!d;}' \
                -e 'x;/FONTSTYLES==/!d;'  |  # SELECT PARAGRAPH CONTAINING FONT S...
                sed 's/^-//g'             |  # REMOVE LEADING -
                grep -v "FONTSTYLES"`        # RM LINE CONTAINING FONT S...
    else
  
    FONTSTYLES=`find $FONTFAMILY/src -name "*.sfdir" | \
                rev | cut -d "/" -f 1 | rev | \
                sed 's/.sfdir//g'` 
    fi
    if [ `echo $FONTSTYLES | wc -c` -lt 2 ]; then

    FONTSTYLES=`find $FONTFAMILY/src -name "*.sfdir" | \
                rev | cut -d "/" -f 1 | rev | \
                sed 's/.sfdir//g'` 
    fi

   # ----------------------------------------------------------- #
     cat $TMPLT_AKKRDNSLIDER                                          >> $INDEX
   # ----------------------------------------------------------- #

    echo '<div class="sixteen columns accordion" id="sortable">'      >> $INDEX
    echo '<button id="resetDemoText">x</button>'                      >> $INDEX

    COUNT=100 ; EXCLUDECOUNT=0
    for FONTSTYLESRC in $FONTSTYLES
     do

        if [ `echo $FONTSTYLESRC | grep "^XX" | wc -c` -gt 2 ]; then
              HIDE="excluded"
              EXCLUDECOUNT=`expr $EXCLUDECOUNT + 1`
        else
              HIDE=""
        fi

        FONTSTYLESRC=`echo $FONTSTYLESRC | \
                      sed 's/^XX//g' | \
                      sed 's/.sfdir//g'`

        if [ `find $FONTFAMILY/src -name "$FONTSTYLESRC.sfdir" | wc -c` \
             -gt 1 ]; then

        FONTSTYLESRC=`find $FONTFAMILY/src -name "$FONTSTYLESRC.sfdir"`
        STYLENAME=`grep -h "FullName" $FONTSTYLESRC/font.props | \
                   cut -d ":" -f 2 | sed "s/^[ \t]*//"`
        STYLENAMEWWW=`echo $STYLENAME | \
                      sed 's/ /jfdDw24e/g' | \
                      sed 's/[^a-zA-Z0-9 ]//g' | \
                      sed 's/jfdDw24e/-/g' | \
                      tr [:upper:] [:lower:]`

        FONTSTYLESRCNAME=`basename $FONTSTYLESRC | sed "s/.sfdir//g"`

        cat $TMPLT_AKKORDION | \
        sed "s/accordion-section positiv/& $HIDE/g" | \
        sed "s/STYLENAMEWWW/$STYLENAMEWWW/g" | \
        sed "s/STYLENAME/$STYLENAME/g" | \
        sed "s/-COUNT/-$COUNT/g" | \
        sed "s/FAMILYNAME/$STYLENAME/g"                               >> $INDEX

      # ------------------------------------------------- #
      # FLOWTEXT CONFIG
      # ------------------------------------------------- #
        if [ `echo $HIDE | wc -c` -lt 3 ]; then

        if [ X$FIRSTTIME != X$FONTFAMILY ];then
        FLOWTEXTMASTER=$STYLENAME
        FLOWTEXTMASTERWWW=$STYLENAMEWWW
        FIRSTTIME=$FONTFAMILY
      # echo "for the first time"
        FLOWTEXTARRAY=""
        fi
        FLOWTEXTARRAY=$FLOWTEXTARRAY"\"$STYLENAMEWWW\","
        fi

        fi
      # ------------------------------------------------- #

        COUNT=`expr $COUNT + 1`

       done

    echo '</div>'                                                   >> $INDEX

    if [ $EXCLUDECOUNT -gt 0 ]; then
    echo "<a class=\"fontdemo-showmore jsonly\" \
           href=\"\">and $EXCLUDECOUNT more.</a>" | tr -s ' '       >> $INDEX
    fi

    echo '<br class='clear' /><br />'                               >> $INDEX


  }

# --------------------------------------------------------------------------- #
  function AUTHOR(){

    if [ -f $README ]; then
    AUTHOR=`sed '/^\s*$/d' $README        | # REMOVE EMPTY LINES
            sed -e :a \
                -e '$!N;s/\n=====/=====/;ta' \
                -e 'P;D'                  | # APPEND LINES WITH =====
            sed '/=====$/{x;p;x;}'        | # INSERT EMPTY LINE ABOVE
            sed -e '/./{H;$!d;}' \
                -e 'x;/AUTHOR.*==/!d;'    | # SELECT PARAGRAPH CONTAINING AUTHOR
            grep -v "AUTHOR"`               # RM LINE CONTAINING AUTHOR
    else
  
    AUTHOR=""
  
    fi
    if [ `echo $AUTHOR | wc -c` -gt 2 ]; then

    AUTHOR=`echo $AUTHOR | \
            pandoc -r markdown -w html | \
            sed 's/<\/*p>//g'`

    echo '<div class="fourteen columns">'                           >> $INDEX
    echo $AUTHOR                                                    >> $INDEX
    echo '</div>'                                                   >> $INDEX
    echo '<br class='clear' /><br />'                               >> $INDEX
    fi

  }

# --------------------------------------------------------------------------- #
  function LICENSE(){

    if [ -f $README ]; then
    LICENSE=`sed '/^\s*$/d' $README |     # REMOVE EMPTY LINES
             sed -e :a \
                 -e '$!N;s/\n=====/=====/;ta' \
                 -e 'P;D' |               # APPEND LINES WITH =====
             sed '/=====$/{x;p;x;}' |     # INSERT EMPTY LINE ABOVE
             sed -e '/./{H;$!d;}' \
                 -e 'x;/LICENSE==/!d;' |  # SELECT PARAGRAPH CONTAINING OR
             grep -v "LICENSE=="`         # RM LINE CONTAINING AUTHOR
    else
  
    LICENSE="no license provided"
  
    fi
    if [ `echo $LICENSE | wc -c` -lt 2 ]; then

    LICENSE="no license provided"

    fi

    LICENSE=`echo $LICENSE | pandoc -r markdown -w html | sed 's/<\/*p>//g'`

    echo '<div class="fourteen columns">'                           >> $INDEX
    echo $LICENSE                                                   >> $INDEX
    echo '</div>'                                                   >> $INDEX
    echo '<br class='clear' /><br />'                               >> $INDEX

  }

# --------------------------------------------------------------------------- #
  function SPECIMEN(){


    for SPECIMEN in `find $FONTFAMILY/specimen -name "*.*"`
     do 

        SPECIMENTYPE=`echo $SPECIMEN | rev | cut -d "." -f 1 | rev`

        if [ X$SPECIMENTYPE == Xhead ]; then

             cat $SPECIMEN >> $CSSCOLLECT

        fi
        if [ X$SPECIMENTYPE == Xjpg ]; then

             cpifnewer $SPECIMEN $SPECIMENTARGET/`basename $SPECIMEN`
             JPG=`echo $SPECIMEN | rev | cut -d "/" -f 1-2 | rev`
             echo "<img class=\"sixteen columns specipic\" \
                    src=\"$JPG\" />" | tr -s ' '                  >> $INDEX
             echo "<img class=\"sixteen columns specipic\" \
                    src=\"$JPG\" />" | tr -s ' '
        fi
        if [ X$SPECIMENTYPE == Xbody ]; then

            cat $SPECIMEN                                         >> $INDEX
        fi

    done

  }

# --------------------------------------------------------------------------- #
  function DOWNLOAD(){

    echo '<div class="eight columns">'                              >> $INDEX

    for DOWNLOAD in `find $EXPORTTARGET -name "*.zip"`
     do
        TYPE=`echo $DOWNLOAD | rev | cut -d "." -f 2 | rev`
        DOWNLOADLINK=export/${DOWNLOAD#*export/}

        echo "<a class=\"button positiv\" \
              href="$DOWNLOADLINK">$TYPE</a>" | tr -s ' '           >> $INDEX
    done

#   echo '(Download)'                                               >> $INDEX
    echo '</div>'                                                   >> $INDEX
    echo '<br class='clear' /><br />'                               >> $INDEX

  }

# --------------------------------------------------------------------------- #
  function FLOWTEXT(){
    
    cat $TMPLT_FLOWTEXT                                             >> $INDEX

  }
# --------------------------------------------------------------------------- #









# =========================================================================== #
# CREATE WWW USER INTERFACE
# =========================================================================== #

 for FONTFAMILY in $FONTS
  do
      FAMILYNAME=`grep -h "FamilyName" $FONTFAMILY/src/*/font.props | \
                  cut -d ":" -f 2 | \
                  awk '{print length, $0;}' | sort -n | \
                  head -n 1 | cut -d " " -f 2- | \
                  sed "s/^[ \t]*//"`
      FAMILYNAMEWWW=`echo $FAMILYNAME | \
                     sed 's/ /jfdDw24e/g' | \
                     sed 's/[^a-zA-Z0-9 ]//g' | \
                     sed 's/jfdDw24e/-/g' | \
                     tr [:upper:] [:lower:]`

      SPECIMENSRC=$FONTFAMILY/specimen
      if [ -f $CSSCOLLECT ]; then rm $CSSCOLLECT ; fi
      touch $CSSCOLLECT

      FAMILYTARGET=$WWWDIR/`basename $FONTFAMILY`
      WEBFONTTARGET=$FAMILYTARGET/webfont
      SPECIMENTARGET=$FAMILYTARGET/specimen
      EXPORTTARGET=$FAMILYTARGET/export

      ISLIST="false"
      CUSTOMCSS="../css/fontain_font.css"
      CSS=$WEBFONTTARGET/webfont.css
      INDEX=$FAMILYTARGET/index.html

      mkdir -p $FAMILYTARGET
      mkdir -p $WEBFONTTARGET
      mkdir -p $SPECIMENTARGET
      mkdir -p $EXPORTTARGET
      if [ -f $CSS ]; then rm $CSS ; fi

      README=$FONTFAMILY/$READMENAME


# --------------------------------------------------------------------------- #
# COLLECT FILES 
# --------------------------------------------------------------------------- #

     FONTSTYLES=`find $FONTFAMILY/src -name "*.sfdir" | \
                 rev | cut -d "/" -f 1 | rev | \
                 sed 's/.sfdir//g'`

     COUNT=100 ; EXCLUDECOUNT=0
     for FONTSTYLESRC in $FONTSTYLES
      do
        FONTSTYLESRC=`echo $FONTSTYLESRC | \
                      sed 's/.sfdir//g'`

        if [ `find $FONTFAMILY/src -name "$FONTSTYLESRC.sfdir" | wc -c` \
             -gt 1 ]; then
        FONTSTYLESRC=`find $FONTFAMILY/src -name "$FONTSTYLESRC.sfdir"`
        STYLENAME=`grep -h "FullName" $FONTSTYLESRC/font.props | \
                   cut -d ":" -f 2 | sed "s/^[ \t]*//"`
        STYLENAMEWWW=`echo $STYLENAME | \
                      sed 's/ /jfdDw24e/g' | \
                      sed 's/[^a-zA-Z0-9 ]//g' | \
                      sed 's/jfdDw24e/-/g' | \
                      tr [:upper:] [:lower:]`

        FONTSTYLESRCNAME=`basename $FONTSTYLESRC | sed "s/.sfdir//g"`

        EOTFILE=`find $FONTFAMILY -name "${FONTSTYLESRCNAME}.eot"`
        cpifnewer $EOTFILE $WEBFONTTARGET/`basename $EOTFILE` 
        EOTFILE=`basename $EOTFILE`

        WOFFFILE=`find $FONTFAMILY -name "${FONTSTYLESRCNAME}.woff"`
        cpifnewer $WOFFFILE $WEBFONTTARGET/`basename $WOFFFILE`
        WOFFFILE=`basename $WOFFFILE`

        SVGFILE=`find $FONTFAMILY -name "${FONTSTYLESRCNAME}.svg"`
        cpifnewer $SVGFILE $WEBFONTTARGET/`basename $SVGFILE`
        SVGFILE=`basename $SVGFILE`

        TTFFILE=`find $FONTFAMILY -name "${FONTSTYLESRCNAME}.ttf"`
        cpifnewer $TTFFILE $WEBFONTTARGET/`basename $TTFFILE`
        TTFFILE=`basename $TTFFILE`

        cat $TMPLT_CSS | \
        sed "s/EOTFILE/$EOTFILE/g" | \
        sed "s/SVGFILE/$SVGFILE/g" | \
        sed "s/TTFFILE/$TTFFILE/g" | \
        sed "s/WOFFFILE/$WOFFFILE/g" | \
        sed "s/FONTFAMILY/$STYLENAMEWWW/g"                          >> $CSS
        echo                                                        >> $CSS

        fi

     done

   # ===================================================================== #
   # CREATE DOWNLOADS
   # ===================================================================== #
     ZIPNAME=$FAMILYNAMEWWW

   # --------------------------------------------------------------------- #
   # CREATE DIRECTORIES
   # --------------------------------------------------------------------- #
     for EXPORT in ttf otf ufo webfont tex
      do
         mkdir -p $EXPORTTARGET/$EXPORT
     done

   # --------------------------------------------------------------------- #
   # ZIP WEBFONT DIRECTORY (IF THERE EXISTS ANY NEWER SOURCE)
   # --------------------------------------------------------------------- #
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

       cd - > /dev/null

   # MOVE ZIP TO LOCATION
   # --------------------------------------------------------------------- #
       mv $WEBFONTTARGET/${ZIPNAME}.webfont.zip \
          $EXPORTTARGET/webfont
     fi

   # --------------------------------------------------------------------- #
   # ZIP THE REST (IF THERE EXISTS A NEWER SOURCE)
   # --------------------------------------------------------------------- #
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
   # --------------------------------------------------------------------- #

           mv $FONTFAMILY/export/$FORMAT/X-${ZIPNAME}.$FORMAT.zip \
              $EXPORTTARGET/$FORMAT/${ZIPNAME}.$FORMAT.zip
        fi
     done
   # ===================================================================== #         
# --------------------------------------------------------------------------- #


# --------------------------------------------------------------------------- #
# GET UI CONFIGURATION FROM README
# --------------------------------------------------------------------------- #
  if [ -f $README ]; then
  SECTIONS=`sed '/^\s*$/d' $README |         # REMOVE EMPTY LINES
            sed -e :a \
            -e '$!N;s/\n=====/=====/;ta' \
            -e 'P;D' |                       # APPEND LINES WITH =====
            sed '/=====$/{x;p;x;}' |         # INSERT EMPTY LINE ABOVE
            sed -e '/./{H;$!d;}' \
            -e 'x;/UI CONFIGURATION==/!d;' | # SELECT PARAGRAPH CONTAINING UI C..
            grep -v "UI CONFIGURATION"`      # RM LINE CONTAINING UI C..
  else
            SECTIONS="AKKORDEON DOWNLOAD AUTHOR SPECIMEN LICENSE"
  fi
# --------------------------------------------------------------------------- #
# MAKE SURE THERE IS AT LEAST AKKORDEON AND DOWNLOAD
# --------------------------------------------------------------------------- #
  if [ `echo $SECTIONS | grep "DOWNLOAD" | wc -l` -lt 1 ]
  then  SECTIONS="DOWNLOAD $SECTIONS" ; fi
  if [ `echo $SECTIONS | grep "AKKORDEON" | wc -l` -lt 1 ]
  then  SECTIONS="AKKORDEON $SECTIONS" ; fi

# --------------------------------------------------------------------------- #
# CREATE HTML FILE
# --------------------------------------------------------------------------- #
  cat $TMPLT_HEAD                                                   >  $INDEX
  sed -i "s,ISLIST,$ISLIST,g"                                          $INDEX
  sed -i "s,CUSTOMCSS,$CUSTOMCSS,g"                                    $INDEX
# --------------------------------------------------------------------------- #


# --------------------------------------------------------------------------- #
# JUST DO IT
# --------------------------------------------------------------------------- #
  for SACTION in $SECTIONS
   do
      if [ `grep "function $SACTION" $0 | wc -l` -gt 0 ]; then
 
        $SACTION 

      fi
  done
# --------------------------------------------------------------------------- #
  cat $TMPLT_FOOT                                                   >> $INDEX
# --------------------------------------------------------------------------- #


  sed -i "s/FONTFAMILY/$FAMILYNAME/g"                                  $INDEX
  FLOWTEXTARRAY="[ $FLOWTEXTARRAY ];"
  sed -i "s/FLOWTEXTARRAY/$FLOWTEXTARRAY/g"                            $INDEX
  sed -i "s/FLOWTEXTMASTERWWW/$FLOWTEXTMASTERWWW/g"                    $INDEX
  sed -i "s/FLOWTEXTMASTER/$FLOWTEXTMASTER/g"                          $INDEX

  tac $INDEX | sed -n '/HEADINJECTION/,$p' | tac         >  $TMPDIR/index.tmp
  cat $CSSCOLLECT                                        >> $TMPDIR/index.tmp
  rm  $CSSCOLLECT
  cat $INDEX | sed -n '/HEADINJECTION/,$p'               >> $TMPDIR/index.tmp
  sed -i 's/HEADINJECTION//g'                               $TMPDIR/index.tmp 

  mv $TMPDIR/index.tmp $INDEX
  sed -i "s/$NLPROTECT/\n/g"                                           $INDEX

# --------------------------------------------------------------------------- #
 done


# =========================================================================== #
# CREATE MAIN INDEX
# =========================================================================== #
  HEADINJECTION=""; HIDE=""
  INDEX=$WWWDIR/index.html
  CUSTOMCSS="css/fontain_list.css"
  ISLIST="true"
  CSSCOLLECT=$TMPDIR/css.tmp
  if [ -f $CSSCOLLECT ]; then rm $CSSCOLLECT ; fi

# --------------------------------------------------------------------------- #
  cat $TMPLT_HEAD | \
  sed 's,href="../,href=",g' | sed 's,src="../,src=",g'             >  $INDEX
# sed -i 's,fontain.css,fontainlist.css,g'                             $INDEX
# sed -i 's,fontain.js,fontainlist.js,g'                               $INDEX
  sed -i "s,ISLIST,$ISLIST,g"                                          $INDEX
  sed -i "s,CUSTOMCSS,$CUSTOMCSS,g"                                    $INDEX

  cat $TMPLT_AKKRDNSLIDER                                           >> $INDEX
  echo '<div class="sixteen columns accordion" id="sortable">'      >> $INDEX
  echo '<button id="resetDemoText">x</button>'                      >> $INDEX
# --------------------------------------------------------------------------- #
  README=README.md

  if [ -f $README ]; then
  FONTSTYLES=`sed '/^\s*$/d' $README    |  # REMOVE EMPTY LINES
              sed 's/^ .*/XX&/'         |  # REPLACE LEADING BLANK WITH XX
              sed 's/ //g'              |  # REMOVE SPACES (WORKAROUND!!!!)
              sed -e :a \
              -e '$!N;s/\n=====/=====/;ta' \
              -e 'P;D'                  |  # APPEND LINES WITH =====
              sed '/=====$/{x;p;x;}'    |  # INSERT EMPTY LINE ABOVE
              sed -e '/./{H;$!d;}' \
              -e 'x;/FONTSTYLES==/!d;'  |  # SELECT PARAGRAPH CONTAINING FONT S...
              sed 's/^-//g'             |  # REMOVE LEADING -
              grep -v "FONTSTYLES"`        # RM LINE CONTAINING FONT S...
  else

  FONTSTYLES=`find $FONTFAMILY/src -name "*.sfdir" | \
              rev | cut -d "/" -f 1 | rev | \
              sed 's/.sfdir//g'` 
  fi
  if [ `echo $FONTSTYLES | wc -c` -lt 2 ]; then

  FONTSTYLES=`find $FONTFAMILY/src -name "*.sfdir" | \
              rev | cut -d "/" -f 1 | rev | \
              sed 's/.sfdir//g'` 
  fi
# --------------------------------------------------------------------------- #

  COUNT=100
  for FONTSTYLE in $FONTSTYLES
   do
       if [ `echo $FONTSTYLE | grep "^XX" | wc -c` -lt 1 ]; then

       FONTPATH=`find $WWWDIR -name "${FONTSTYLE}.ttf" | \
                 rev | cut -d "/" -f 3- | rev`

       FONTLINK=`echo $FONTPATH | \
                 sed "s,$WWWDIR/,,g"`

       CSS=$FONTLINK/webfont/webfont.css

       echo "<link rel=\"stylesheet\" href=\"$CSS\">" >> $CSSCOLLECT

       FONTPROPS=`find fonts -name "${FONTSTYLE}.sfdir" -type d`/font.props
       STYLENAME=`grep -h "FullName" $FONTPROPS | \
                  cut -d ":" -f 2 | sed "s/^[ \t]*//"`
       FAMILYNAME=$STYLENAME
       STYLENAMEWWW=`echo $STYLENAME | \
                     sed 's/ /jfdDw24e/g' | \
                     sed 's/[^a-zA-Z0-9 ]//g' | \
                     sed 's/jfdDw24e/-/g' | \
                     tr [:upper:] [:lower:]`

       cat $TMPLT_AKKORDION | \
       sed "s,href=\"\",href=\"$FONTLINK\",g" | \
       sed "s/accordion-section positiv/& $HIDE/g" | \
       sed "s/STYLENAMEWWW/$STYLENAMEWWW/g" | \
       sed "s/STYLENAME/$STYLENAME/g" | \
       sed "s/-COUNT/-$COUNT/g" | \
       sed "s/FAMILYNAME/$FAMILYNAME/g"                             >> $INDEX

       fi

       COUNT=`expr $COUNT + 1`
  done

# --------------------------------------------------------------------------- #
  echo '</div>'                                                     >> $INDEX
  cat $TMPLT_FOOT                                                   >> $INDEX
# --------------------------------------------------------------------------- #

  tac $INDEX | sed -n '/HEADINJECTION/,$p' | tac         >  $TMPDIR/index.tmp
  cat $CSSCOLLECT                                        >> $TMPDIR/index.tmp
  rm  $CSSCOLLECT
  cat $INDEX | sed -n '/HEADINJECTION/,$p'               >> $TMPDIR/index.tmp
  sed -i 's/HEADINJECTION//g'                               $TMPDIR/index.tmp 

  mv $TMPDIR/index.tmp $INDEX
  sed -i "s/$NLPROTECT/\n/g"                                           $INDEX
  TITLE="fontain = a font-collection (and a font-collection-system)"
  sed -i "s/FONTFAMILY on fontain/$TITLE/g"                            $INDEX




exit 0;

