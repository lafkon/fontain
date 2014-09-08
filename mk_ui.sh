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

# LICENSE/READMENAMES (MD OR TXT?)
# ----------------------------------------------------------------- #
  READMENAME=README.md
  LICENSENAME=LICENSE.txt

# COPY STATIC STUFF 
# ----------------------------------------------------------------- #
  cp -r `ls -d lib/ui/* | egrep -v "templates"` $WWWDIR


# --------------------------------------------------------------------------- #
# FUNCTIONS
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
                -e 'x;/FONTSTYLES/!d;'   |  # SELECT PARAGRAPH CONTAINING FONT S...
                sed 's/^-//g'             |  # REMOVE LEADING -
                grep -v "FONTSTYLES"`       # RM LINE CONTAINING FONT S...
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

        # echo $STYLENAME
        # echo $STYLENAMEWWW
        # echo $FONTSTYLESRCNAME
        # echo

        EOTFILE=`find $FONTFAMILY -name "${FONTSTYLESRCNAME}.eot"`
        cp -p $EOTFILE $WEBFONTTARGET
        EOTFILE=`basename $EOTFILE`

        WOFFFILE=`find $FONTFAMILY -name "${FONTSTYLESRCNAME}.woff"`
        cp -p $WOFFFILE $WEBFONTTARGET
        WOFFFILE=`basename $WOFFFILE`

        SVGFILE=`find $FONTFAMILY -name "${FONTSTYLESRCNAME}.svg"`
        cp -p $SVGFILE $WEBFONTTARGET
        SVGFILE=`basename $SVGFILE`

        TTFFILE=`find $FONTFAMILY -name "${FONTSTYLESRCNAME}.ttf"`
        cp -p $TTFFILE $WEBFONTTARGET
        TTFFILE=`basename $TTFFILE`

        cat $TMPLT_CSS | \
        sed "s/EOTFILE/$EOTFILE/g" | \
        sed "s/SVGFILE/$SVGFILE/g" | \
        sed "s/TTFFILE/$TTFFILE/g" | \
        sed "s/WOFFFILE/$WOFFFILE/g" | \
        sed "s/FONTFAMILY/$STYLENAMEWWW/g"                          >> $CSS
        echo                                                        >> $CSS

        cat $TMPLT_AKKORDION | \
        sed "s/accordion-section positiv/& $HIDE/g" | \
        sed "s/STYLENAMEWWW/$STYLENAMEWWW/g" | \
        sed "s/STYLENAME/$STYLENAME/g" | \
        sed "s/-COUNT/-$COUNT/g" | \
        sed "s/FAMILYNAME/$FAMILYNAME/g"                            >> $INDEX

        COUNT=`expr $COUNT + 1`

        fi

       done

    if [ $EXCLUDECOUNT -gt 0 ]; then
    echo "<a class="fontdemo-showmore jsonly" \
           href="">and $EXCLUDECOUNT more.</a>" | tr -s ' '         >> $INDEX
    fi


   # ----------------------------------------------------------- #
     echo '</div>'                                                  >> $INDEX
     cat $TMPLT_AKKRDNSLIDER                                        >> $INDEX
   # ----------------------------------------------------------- #


  }

# --------------------------------------------------------------------------- #
  function AUTHOR(){

    if [ -f $README ]; then
    AUTHOR=`sed '/^\s*$/d' $README |        # REMOVE EMPTY LINES
            sed -e :a \
                -e '$!N;s/\n=====/=====/;ta' \
                -e 'P;D' |                  # APPEND LINES WITH =====
            sed '/=====$/{x;p;x;}' |        # INSERT EMPTY LINE ABOVE
            sed -e '/./{H;$!d;}' \
                -e 'x;/AUTHOR.*==/!d;' |    # SELECT PARAGRAPH CONTAINING AUTHOR
            grep -v "AUTHOR"`               # RM LINE CONTAINING AUTHOR
    else
  
    AUTHOR=""
  
    fi
    if [ `echo $AUTHOR | wc -c` -gt 2 ]; then

    AUTHOR=`echo $AUTHOR | \
            pandoc -r markdown -w html | \
            sed 's/<\/*p>//g'`

    echo '<hr class="hrsection" />'                  >> $INDEX
    echo '<div class="fourteen columns">'            >> $INDEX
    echo $AUTHOR  >> $INDEX
    echo '</div>'                                    >> $INDEX
    echo '<br class='clear' />'                      >> $INDEX
    echo '<hr class="hrsection" />'                  >> $INDEX
    echo '<br class='clear' />'                      >> $INDEX

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

    LICENSE="no author provided"

    fi

    LICENSE=`echo $LICENSE | \
             pandoc -r markdown -w html | \
             sed 's/<\/*p>//g'`

    echo $LICENSE

  }

# --------------------------------------------------------------------------- #
  function SPECIMEN(){

    echo "now writing specimen"

  }

# --------------------------------------------------------------------------- #
  function DOWNLOAD(){

    echo "now writing download"

  }

# --------------------------------------------------------------------------- #
  function FLOWTEXT(){

    echo "now writing flowtext"

  }
# --------------------------------------------------------------------------- #










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

      README=$FONTFAMILY/$READMENAME

# --------------------------------------------------------------------------- #
# GET UI CONFIGURATION FROM README
# --------------------------------------------------------------------------- #
  if [ -f $README ]; then
  SECTIONS=`sed '/^\s*$/d' $README |        # REMOVE EMPTY LINES
            sed -e :a \
            -e '$!N;s/\n=====/=====/;ta' \
            -e 'P;D' |                      # APPEND LINES WITH =====
            sed '/=====$/{x;p;x;}' |        # INSERT EMPTY LINE ABOVE
            sed -e '/./{H;$!d;}' \
            -e 'x;/UI CONFIGURATION/!d;' |  # SELECT PARAGRAPH CONTAINING UI C..
            grep -v "UI CONFIGURATION"`     # RM LINE CONTAINING UI C..
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

  echo '<div class="sixteen columns accordion" id="sortable">'      >> $INDEX

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



 done



exit 0;


















  README=README_2.md




















exit 0;

