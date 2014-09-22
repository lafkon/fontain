#!/bin/bash

# PATH TO FONT DIRECTORY (TOP LEVEL)
# --------------------------------------------------------------------------- #
  FONTS=`ls -d -1 fonts/*`
# --------------------------------------------------------------------------- #
  OUTPUTDIR=$1
  TMPDIR=/tmp

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
          if [ $ANSWER != y ] ; then echo "Bye-bye"; exit 0; fi
    fi

  WWWDIR=$OUTPUTDIR
  echo "writing to $WWWDIR"; sleep 3 # SOME TIME TO CHANGE YOUR MIND

# --------------------------------------------------------------------------- #
# TEMPLATES
# --------------------------------------------------------------------------- #
  TMPLT_CSS=lib/ui/templates/css.template
  TMPLT_HTMLHEAD=lib/ui/templates/htmlhead.template
  TMPLT_HTMLFOOT=lib/ui/templates/htmlfoot.template
  TMPLT_HEAD_LIST=lib/ui/templates/head_list.template
  TMPLT_HEAD_PAGE=lib/ui/templates/head_page.template
  TMPLT_HEAD=lib/ui/templates/head.template
  TMPLT_FOOT=lib/ui/templates/foot.template
  TMPLT_AKKORDEON=lib/ui/templates/akkordeon.template
  TMPLT_DOWNLOAD=lib/ui/templates/download.template
  TMPLT_FLOWTEXT=lib/ui/templates/flowtext.template
  TMPLT_AUTHOR=lib/ui/templates/author.template
  TMPLT_LICENSE=lib/ui/templates/license.template
  TMPLT_SPECIMEN=lib/ui/templates/specimen.template
  TMPLT_DOWNLOAD=lib/ui/templates/download.template
  TMPLT_INFO=lib/ui/templates/information.template
  TMPLT_FONTLOG=lib/ui/templates/fontlog.template

# LICENSE/READMENAMES (MD OR TXT?)
# --------------------------------------------------------------------------- #
  READMENAME=README.md ; LICENSENAME=LICENSE.txt

# SET VARIABLES
# --------------------------------------------------------------------------- #
  CSSCOLLECT=$TMPDIR/css.tmp

# COPY STATIC STUFF 
# --------------------------------------------------------------------------- #
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
            echo "$CPTARGETBASE is up-to-date"
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

    grep "<!-- PRE -->" $TMPLT_AKKORDEON | sed 's/<!-- PRE -->//g'  >> $INDEX    
  # ------------------------------------------------------------------------- #

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

        grep "<!-- LOOP -->" $TMPLT_AKKORDEON | \
        sed "s/accordion-section positiv/& $HIDE/g" | \
        sed "s/STYLENAMEWWW/$STYLENAMEWWW/g" | \
        sed "s/STYLENAME/$STYLENAME/g" | \
        sed "s/-COUNT/-$COUNT/g" | \
        sed "s/FAMILYNAME/$STYLENAME/g" | \
        sed 's/data-typeclass="CLASSIFICATION"//g' | \
        sed 's/<!-- LOOP -->//g'                                    >> $INDEX

  # ------------------------------------------------------------------------- #
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
  # ------------------------------------------------------------------------- #
    FLOWTEXTARRAY=`echo $FLOWTEXTARRAY | sed 's/,$//g'`

    if [ $EXCLUDECOUNT -gt 0 ]; then
         grep "<!-- POST -->" $TMPLT_AKKORDEON | \
         sed "s/EXCLUDECOUNT/$EXCLUDECOUNT/g" | \
         sed 's/<!-- POST -->//g'                                   >> $INDEX 
    else
         grep "<!-- POST -->" $TMPLT_AKKORDEON | \
         grep -v EXCLUDECOUNT | sed 's/<!-- POST -->//g'            >> $INDEX 
    fi

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

    cat $TMPLT_AUTHOR | sed "s|AUTHOR|$AUTHOR|g"                    >> $INDEX

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

    cat $TMPLT_LICENSE | sed "s|LICENSE|$LICENSE|g"                 >> $INDEX

  }
# --------------------------------------------------------------------------- #
  function GENERALINFORMATION(){

    EMPTYLINE=EL${RANDOM}EL

    if [ -f $README ]; then
    if [ `grep "GENERAL INFORMATION" $README | wc -l` -gt 0 ]; then

         grep   "<!-- PRE -->" $TMPLT_INFO | \
         sed  's/<!-- PRE -->//g'                                    >> $INDEX

         sed "s/^\s*$/$EMPTYLINE/g" $README    | # FOO EMPTY LINES
         sed -e :a \
             -e '$!N;s/\n=====/=====/;ta' \
             -e 'P;D' |                          # APPEND LINES WITH =====
         sed '/=====$/{x;p;x;}' |                # INSERT EMPTY LINE ABOVE
         sed -e '/./{H;$!d;}' \
             -e 'x;/GENERAL INFORMATION==/!d;' | # SELECT PARAGRAPH
         grep -v "GENERAL INFORMATION=="       | # RM LINE CONTAINING AUTHOR
         sed "s/$EMPTYLINE/\n/g"               | # BAR EMPTY LINES
         pandoc -r markdown -w html                                 >> $INDEX

         grep   "<!-- POST -->" $TMPLT_INFO | \
         sed  's/<!-- POST -->//g'                                  >> $INDEX

    fi
    fi


  }
# --------------------------------------------------------------------------- #
  function SPECIMEN(){

    grep "<!-- PRE -->" $TMPLT_SPECIMEN | sed 's/<!-- PRE -->//g'   >> $INDEX

    if [ -d $FONTFAMILY/specimen ]; then
    for SPECIMEN in `find $FONTFAMILY/specimen -name "*.*" | sort`
     do 
        SPECIMENTYPE=`echo $SPECIMEN | rev | cut -d "." -f 1 | rev`

        if [ X$SPECIMENTYPE == Xhead ]; then

             cat $SPECIMEN >> $CSSCOLLECT
        fi
        if [ X$SPECIMENTYPE == Xjpg ] ||
           [ X$SPECIMENTYPE == Xgif ] ||
           [ X$SPECIMENTYPE == Xpng ] ; then

             cpifnewer $SPECIMEN $SPECIMENTARGET/`basename $SPECIMEN`
             IMG=`echo $SPECIMEN | rev | cut -d "/" -f 1-2 | rev`
             grep "<!-- LOOP -->" $TMPLT_SPECIMEN | \
             sed "s,SPEZIPIC,$IMG,g" | \
             sed 's/<!-- LOOP -->//g'                             >> $INDEX
        fi
        if [ X$SPECIMENTYPE == Xsvg ] ; then

             PNG=$SPECIMENTARGET/`basename $SPECIMEN | cut -d "." -f 1`.png
             inkscape --export-png=$PNG $SPECIMEN
             PNG=`echo $PNG | rev | cut -d "/" -f 1-2 | rev`
             grep "<!-- LOOP -->" $TMPLT_SPECIMEN | \
             sed "s,SPEZIPIC,$PNG,g" | \
             sed 's/<!-- LOOP -->//g'                             >> $INDEX
        fi
        if [ X$SPECIMENTYPE == Xbody ]; then

            cat $SPECIMEN                                         >> $INDEX
        fi 
    done
    fi

    grep "<!-- POST -->" $TMPLT_SPECIMEN | sed 's/<!-- POST -->//g' >> $INDEX
  }
# --------------------------------------------------------------------------- #
  function DOWNLOAD(){

    grep "<!-- PRE -->" $TMPLT_DOWNLOAD | sed 's/<!-- PRE -->//g'   >> $INDEX

    for DOWNLOAD in `find $EXPORTTARGET -name "*.zip"`
     do
        TYPE=`echo $DOWNLOAD | rev | cut -d "." -f 2 | rev`
        DOWNLOADLINK=export/${DOWNLOAD#*export/}

        grep "<!-- LOOP -->" $TMPLT_DOWNLOAD | \
        sed "s,DOWNLOADLINK,$DOWNLOADLINK,g" | \
        sed "s,TYPE,$TYPE,g"                 | \
        sed 's/<!-- LOOP -->//g'                                   >> $INDEX

    done

    grep "<!-- POST -->" $TMPLT_DOWNLOAD | sed 's/<!-- POST -->//g' >> $INDEX

  }

# --------------------------------------------------------------------------- #
  function FONTLOG(){

    if [ -f $FONTLOG ]; then

     cat $TMPLT_FONTLOG                                             >> $INDEX   
     cat $FONTLOG | sed 's/@/.[.AT.]./g'        > ${EXPORTTARGET}/FONTLOG.txt

    fi

  }
# --------------------------------------------------------------------------- #
  function FLOWTEXT(){
    
    cat $TMPLT_FLOWTEXT                                             >> $INDEX

  }
# --------------------------------------------------------------------------- #
  function READMESECTIONS(){
    
    NEWREADME=$1
    XX=X${RANDOM}X # TMP UNIQ ID
    XY=X${RANDOM}Y # TMP UNIQ ID
    YY=Y${RANDOM}Y # TMP UNIQ ID
    YZ=Y${RANDOM}Z # TMP UNIQ ID
    for S in `echo $SECTIONS2INCLUDE | \
              sed 's/ /zTv63cH/g'  | sed 's/|/ /g'`
    do S=`echo $S | sed 's/zTv63cH/ /g'`
    SECTIONS=$SECTIONS\|${XY}$S${XX}== ; done
    SECTIONS=`echo $SECTIONS | cut -d "|" -f 2-`
   
    sed "s/^\s*$/$YZ/g" $FULLREADME         | \
    sed -e :a \
        -e "$!N;s/\n=====/$XX=====/;ta"  \
        -e 'P;D'                       | \
    sed '/XX=====/{x;p;x;}'            | \
    sed ':a;N;$!ba;/====$/s/\n//g'     | \
    sed "/$XX===*$/s/^/$XY/"           | \
    sed ":a;N;\$!ba;s/\n/$YY/g"        | \
    sed "s/$XY/\n$XY/g"                | \
    egrep "$SECTIONS"                  | \
    sed "s/$XY/\n/g"                   | \
    sed "s/$YY/\n/g"                   | \
    sed "s/$XX/\n/g"                   | \
    sed "s/$YZ//g"                     | \
    uniq                               > $NEWREADME

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

     FONTLOG=$TMPDIR/FONTLOG.txt
     echo ""                       >  $FONTLOG
     echo "  FONTLOG: $FAMILYNAME" >> $FONTLOG
     echo ""                       >> $FONTLOG


     for FONTSTYLESRC in $FONTSTYLES
      do
        FONTSTYLESRC=`echo $FONTSTYLESRC | \
                      sed 's/.sfdir//g'`

        if [ `find $FONTFAMILY/src -name "$FONTSTYLESRC.sfdir" | wc -c` \
             -gt 1 ]; then
        FONTSTYLESRC=`find $FONTFAMILY/src -name "$FONTSTYLESRC.sfdir"`
        FONTPROPS="$FONTSTYLESRC/font.props"
        STYLENAME=`grep -h "FullName" $FONTPROPS | \
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

   # --------------------------------------------------------------------- #
   # EXTRACT FONTLOG
   # --------------------------------------------------------------------- #
        FONTLOG=$TMPDIR/FONTLOG.txt
        echo "  --------------------------------------------"  >> $FONTLOG
        echo "  ${STYLENAME}"                                  >> $FONTLOG
        echo "  --------------------------------------------"  >> $FONTLOG

        if [ `grep ^FontLog: $FONTPROPS | wc -c` -gt 10 ]; then
      # FLCHECKNOW=`grep ^FontLog: $FONTPROPS | md5sum | cut -c 1-16`
        FLCHECKNOW=`grep ^FontLog: $FONTPROPS | \
                    sed 's/ //g' | \
                    sed 's/[^a-zA-Z0-9 ]//g'`
        if [ X$FLCHECKNOW != X$FLCHECKPREV ]; then
         echo ""                                               >> $FONTLOG
         grep ^FontLog: $FONTPROPS    | \
         cut -d ":" -f 2-             | \
         sed 's/^ "//g'               | sed 's/" $//g'     | \
         sed 's/+AAoA-/\n/g'          | sed 's/CgAA-/\n/g' | \
         sed 's/+AAoA/\n/g'           | sed 's/CgAK-/\n/g' | \
         fold -s -w 60                | \
         sed '/^-/!s/^/  /'           | \
         sed 's/^//'                                           >> $FONTLOG
         echo -e "\n"                                          >> $FONTLOG
         FLCHECKPREV=$FLCHECKNOW
        else
          echo "  see above"                                   >> $FONTLOG
        fi
        else
         echo "  no FONTLOG."                                  >> $FONTLOG
        fi
   # --------------------------------------------------------------------- #
        fi

     done

   # ===================================================================== #
   # CREATE DOWNLOADS
   # ===================================================================== #
     ZIPNAME=$FAMILYNAMEWWW

   # --------------------------------------------------------------------- #
   # CREATE DIRECTORIES TO STORE EXPORTS
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

       if [ -f ../../$READMENAME ]; then 
             SECTIONS2INCLUDE="AUTHOR|LICENSE"
             FULLREADME=$FONTFAMILY/$READMENAME
             READMESECTIONS $WEBFONTTARGET/$READMENAME
       fi
       if [ -f $FONTFAMILY/$LICENSENAME ]; then
       cp $FONTFAMILY/$LICENSENAME $WEBFONTTARGET ; fi
       if [ -f $FONTLOG ]; then
       cp $FONTLOG $WEBFONTTARGET ; fi
       cd $WEBFONTTARGET

       zip -r ${ZIPNAME}.webfont.zip *.*

       if [ -f $READMENAME ];         then rm $READMENAME         ; fi
       if [ -f $LICENSENAME ];        then rm $LICENSENAME        ; fi
       if [ -f `basename $FONTLOG` ]; then rm `basename $FONTLOG` ; fi

       cd - > /dev/null

   # MOVE ZIP TO LOCATION
   # --------------------------------------------------------------------- #
       mv $WEBFONTTARGET/${ZIPNAME}.webfont.zip \
          $EXPORTTARGET/webfont
     fi

   # --------------------------------------------------------------------- #
   # ZIP THE REST (IF A NEWER SOURCE EXISTS)
   # --------------------------------------------------------------------- #
     for FORMAT in ttf otf ufo tex
      do
        if [ `find $FONTFAMILY/export/ -name "$FORMAT" -type d | \
              wc -l` -gt 0 ]; then

         NEWESTFILE=`find $FONTFAMILY/export/$FORMAT  \
                           -type f -printf '%T@ %p\n' | \
                     sort -n | tail -1 | cut -f 2- -d " "`
 
         ZIPTARGET=${ZIPNAME}.$FORMAT.zip
 
         if [ `find $EXPORTTARGET/$FORMAT/ -name "*.zip" \
               -newer $NEWESTFILE | wc -l` -gt 0 ]
         then
 
            echo "$ZIPTARGET is up-to-date"
 
         else

            if   [ X$FORMAT = Xtex ]; then
                   SECTIONS2INCLUDE="AUTHOR|LICENSE|TEX HOWTO"
            elif [ X$FORMAT = Xufo ]; then
                   SECTIONS2INCLUDE="AUTHOR|LICENSE|ABOUT UFO"
            else
                   SECTIONS2INCLUDE="AUTHOR|LICENSE"
            fi


            cd $FONTFAMILY/export/$FORMAT

            if [ -f ../../$READMENAME ]; then 
               FULLREADME=../../$READMENAME
               READMESECTIONS $READMENAME
            fi
            if [ -f ../../$LICENSENAME ]; then
            cp ../../$LICENSENAME . ; fi
            if [ -f $FONTLOG ]; then
            cp $FONTLOG . 
            fi

            zip -r X-${ZIPNAME}.$FORMAT.zip *.*
 
            if [ -f $READMENAME ];         then rm $READMENAME         ; fi
            if [ -f $LICENSENAME ];        then rm $LICENSENAME        ; fi
            if [ -f `basename $FONTLOG` ]; then rm `basename $FONTLOG` ; fi
 
            cd - > /dev/null
 
   # MOVE ZIP TO LOCATION
   # --------------------------------------------------------------------- # 
            mv $FONTFAMILY/export/$FORMAT/X-${ZIPNAME}.$FORMAT.zip \
               $EXPORTTARGET/$FORMAT/${ZIPNAME}.$FORMAT.zip
         fi

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
            SECTIONS="AKKORDEON DOWNLOAD AUTHOR LICENSE SPECIMEN"
  fi
# --------------------------------------------------------------------------- #
# MAKE SURE THERE IS AT LEAST AKKORDEON AND DOWNLOAD
# --------------------------------------------------------------------------- #
  if [ `echo $SECTIONS | grep "LICENSE"   | wc -l` -lt 1 ]
  then  SECTIONS="$SECTIONS LICENSE" ; fi
  if [ `echo $SECTIONS | grep "AUTHOR"    | wc -l` -lt 1 ]
  then  SECTIONS="$SECTIONS AUTHOR" ; fi
  if [ `echo $SECTIONS | grep "FONTLOG"   | wc -l` -lt 1 ]
  then  SECTIONS="$SECTIONS FONTLOG" ; fi
  if [ `echo $SECTIONS | grep "DOWNLOAD"  | wc -l` -lt 1 ]
  then  SECTIONS="DOWNLOAD $SECTIONS" ; fi
  if [ `echo $SECTIONS | grep "AKKORDEON" | wc -l` -lt 1 ]
  then  SECTIONS="AKKORDEON $SECTIONS" ; fi



# --------------------------------------------------------------------------- #
# CREATE HTML FILE
# --------------------------------------------------------------------------- #
  cat $TMPLT_HTMLHEAD                                               >  $INDEX
  sed -i "s,ISLIST,$ISLIST,g"                                          $INDEX
  sed -i "s,CUSTOMCSS,$CUSTOMCSS,g"                                    $INDEX
  cat $TMPLT_HEAD_PAGE                                              >> $INDEX
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
  cat $TMPLT_HTMLFOOT                                               >> $INDEX
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

# --------------------------------------------------------------------------- #
 done




# =========================================================================== #
# CREATE MAIN LIST
# =========================================================================== #
  HEADINJECTION=""; HIDE=""
  INDEX=$WWWDIR/index.html
  CUSTOMCSS="css/fontain_list.css"
  ISLIST="true"
  CSSCOLLECT=$TMPDIR/css.tmp
  if [ -f $CSSCOLLECT ]; then rm $CSSCOLLECT ; fi

# --------------------------------------------------------------------------- #
  cat $TMPLT_HTMLHEAD | # USELESS USE OF CAT
  grep -v "webfont/webfont.css" | \
  sed 's,href="../,href=",g' | sed 's,src="../,src=",g'             >  $INDEX
  sed -i "s,ISLIST,$ISLIST,g"                                          $INDEX
  sed -i "s,CUSTOMCSS,$CUSTOMCSS,g"                                    $INDEX
  cat $TMPLT_HEAD_LIST                                              >> $INDEX

  grep "<!-- PRE -->" $TMPLT_AKKORDEON | sed 's/<!-- PRE -->//g'  >> $INDEX
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

  INDEXPAGE="index.html" # EMPTY THIS VARIABLE TO MAKE LINK TO DIRECTORY
  COUNT=100 ; ALREADYINCLUDED="NOTHING$RANDOM"

  for FONTSTYLE in $FONTSTYLES
   do
       if [ `echo $FONTSTYLE | grep "^XX" | wc -c` -lt 1 ]; then

       FONTPATH=`find $WWWDIR -name "${FONTSTYLE}.ttf" | \
                 grep webfont | \
                 rev | cut -d "/" -f 3- | rev`

       FONTLINK=`echo $FONTPATH | \
                 sed "s,$WWWDIR/,,g"`

       CHECK=`echo $FONTLINK | egrep -v "$ALREADYINCLUDED" | wc -l`
       ALREADYINCLUDED="$FONTLINK|$ALREADYINCLUDED"

       if [ $CHECK -gt 0 ];then

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

       THISSRC=`find . -name "${FONTSTYLE}.*" | head -n 1 | cut -d "/" -f 1-3`
       THISREADME=`find $THISSRC -name "$READMENAME" | head -n 1`
       if [ `echo $THISREADME | wc -c` -gt 3 ]; then
       CLASSIFICATION=`grep CLASSIFICATION $THISREADME | # FIND CLASSIFICATION
                       cut -d ":" -f 2                 | # SELECT SECOND FIELD
                       sed 's/^[ \t]*//;s/[ \t]*$//'`    # REMOVE LEADING/TRAILING WHITESPACE
       else
       CLASSIFICATION=""
       fi

       grep "<!-- LOOP -->" $TMPLT_AKKORDEON | \
       sed "s,href=\"\",href=\"$FONTLINK/$INDEXPAGE\",g" | \
       sed "s/accordion-section positiv/& $HIDE/g" | \
       sed "s/STYLENAMEWWW/$STYLENAMEWWW/g" | \
       sed "s/STYLENAME/$STYLENAME/g" | \
       sed "s/-COUNT/-$COUNT/g" | \
       sed "s/FAMILYNAME/$FAMILYNAME/g" | \
       sed "s/CLASSIFICATION/$CLASSIFICATION/g" | \
       sed 's/<!-- LOOP -->//g'                                     >> $INDEX

       if [ X$FIRSTTIME != XNOT ]; then
       THISLINK="../${FONTLINK}/$INDEXPAGE"
       THISPAGE=$FONTPATH/index.html
       FIRSTPAGE=$THISPAGE
       FIRSTLINK=$THISLINK
       FIRSTTIME="NOT"
       else
       THISLINK="../${FONTLINK}/$INDEXPAGE"
       THISPAGE=$FONTPATH/index.html
       sed -i "s,PREVLINK,$PREVLINK,g" $THISPAGE
       sed -i "s,NEXTLINK,$THISLINK,g" $PREVPAGE
       fi
       PREVLINK=$THISLINK
       PREVPAGE=$THISPAGE

       fi
       fi

       COUNT=`expr $COUNT + 1`
  done

  sed -i "s,PREVLINK,$THISLINK,g"  $FIRSTPAGE
  sed -i "s,NEXTLINK,$FIRSTLINK,g" $THISPAGE

# --------------------------------------------------------------------------- #
  grep "<!-- POST -->" $TMPLT_AKKORDEON | sed 's/<!-- POST -->//g' | \
  grep -v EXCLUDECOUNT                                              >> $INDEX

  sed 's,src="../,src=",g' $TMPLT_FOOT                              >> $INDEX
  sed 's,src="../,src=",g' $TMPLT_HTMLFOOT                          >> $INDEX
# --------------------------------------------------------------------------- #

  tac $INDEX | sed -n '/HEADINJECTION/,$p' | tac         >  $TMPDIR/index.tmp
  cat $CSSCOLLECT                                        >> $TMPDIR/index.tmp
  rm  $CSSCOLLECT
  cat $INDEX | sed -n '/HEADINJECTION/,$p'               >> $TMPDIR/index.tmp
  sed -i 's/HEADINJECTION//g'                               $TMPDIR/index.tmp 

  mv $TMPDIR/index.tmp $INDEX
  TITLE="fontain = a font-collection (and a font-collection-system)"
  sed -i "s/FONTFAMILY on fontain/$TITLE/g"                            $INDEX


exit 0;

