// needs to be set in HEAD section of pages
// var isListPage = true;

var accTitlebarHeight = 24;
var of = 1;
var margintop = 15;


var fontSizeSlider;
var fontSizeSlider_CSS;
var fontSizeSlider_classToChange  = 'input.fontdemo';
var flowtextFontSizeSlider;
var flowtextFontSizeSlider_CSS;
var flowtextFontSizeSlider_classToChange  = 'div.flowtext';

var demoTextUnchanged = true;
var orgDemoText;
var orgDemoTextShowmoreButton;
var windowscrolltop = 0;  

var sliderDiv; 
var sliderDivOffset;
var sliderHeight;
var buttonOffset = 25;



// INIT ==============================================================================


$(document).ready(function() {
  
  
  $(window).scroll(function () {
//     if(windowscrolltop != 0) { 
      windowscrolltop = $(window).scrollTop(); 
//     }
  });

  $('.jsonly').css("display", "inline");
  $('.jsonly').css("visibility", "visible");

  checkURL();
  bindLinks();
  
  initSortable();
  initFontDemo();
  initFontSizeSliders();
  initFlowVariants();
  
  if(isListPage) {
    initStaticElements();
  }
  
  
  //expand first/all not-excluded fontdemo
  if(!isListPage) {
    $('.accordion-section').not('.excluded').first().children('.accordion-section-header').children('.accordion-section-title').trigger("click");
  } else if(isListPage) {
    $('.accordion-section').children('.accordion-section-header').children('.accordion-section-title').trigger("click");
    $('.accordion-section').children('.accordion-section-header').children('.accordion-section-title').unbind();
  }

 
 
}); // END document.ready



// INIT ==============================================================================


 function initStaticElements() {
   sliderDiv = $("#slider");
   sliderDivOffset = sliderDiv.offset();
   sliderHeight = sliderDiv.outerHeight();
   
   sliderDiv.css( {'margin-bottom' : -sliderHeight +'px'} );

  
  $( window ).resize( function() {
    sliderHeight = sliderDiv.outerHeight();
    sliderDiv.css( {'margin-bottom' : -sliderHeight +'px'} );
  });

  
  $(window).scroll( function() { 
    if(windowscrolltop > sliderDivOffset.top ) { 
      sliderDiv.addClass('fixed'); 
    }  
    else if(windowscrolltop <= sliderDivOffset.top && sliderDiv.hasClass('fixed')) { 
      sliderDiv.removeClass('fixed'); 
    }
    
    if(windowscrolltop > (sliderDivOffset.top + buttonOffset)) {
      $("#resetDemoText").css( {'top' : windowscrolltop-sliderDivOffset.top -buttonOffset +'px'} );
    }    
    else if(windowscrolltop <= (sliderDivOffset.top + buttonOffset) ) {
      $("#resetDemoText").css( {'top' : 0 +'px'} );
    }
  });
 }


function initSortable() {
  $( "#sortable" ).sortable( {
    items: ".accordion-section",
    axis: "y", 
    cursorAt: { top: 12 },  
    tolerance: "intersect", 
    distance: 5, 
    zIndex: 9999, 
    placeholder: "sortable-placeholder", 
    forcePlaceholderSize: true, 
    forceHelperSize: true,
    cursor: "move",
  });
  
  $( "#sortable" ).sortable( {
    sort: function(event, ui) {  ui.helper.css({'top' : ui.position.top + windowscrolltop + 'px'}); },
    change: function(event, ui) {  windowscrolltop = $(window).scrollTop(); }
  }); 
} // END initSortable


function initFontDemo() {
  $('input.fontdemo').css("margin-top", "-60px"); 
  $('.accordion-section-content').css({
      "height": "24px",
      "margin-top": "-24px"
  });
  
  //========== show/hide excluded fonts
  if ($('a.fontdemo-showmore').length)  {
    $('a.fontdemo-showmore').click(function(e) {
      if($('.excluded:first').is(":hidden"))  {
	orgDemoTextShowmoreButton = $(e.target).html();
	$('.excluded').show('fast');   
	$(e.target).html("show less");
      } else if($('.excluded:first').is(":visible")) {
	$('.excluded').hide('fast'); 
	$(e.target).html(orgDemoTextShowmoreButton);
      } 
      $( "#sortable" ).sortable( "refreshPositions" );
      e.preventDefault();
    });   
  }

  //========== reset textfields to original values
  $('#resetDemoText').click(function(e) {
    if(!demoTextUnchanged) {
      resetDemoText();
    }
  });

  //========== expand/collapse accordion-elements
  $('.accordion-section-title').click(function(e) {
    var target;
    if($(e.target).hasClass("divlink")) {
      target = $(e.target).parent()[0];
    } else {
      target = e.target;
    }
    if($(target).is('.active')) {
      close_accordion_section(target);  
    }
    else {
      open_accordion_section(target);  
    }
    e.preventDefault();
  });
  
  //========== change inputtext on all inputs
  $('input.fontdemo').on("input" , function(e) {
    if(demoTextUnchanged) {
      $('#resetDemoText').show();
      demoTextUnchanged = false;
    }
    $('input.fontdemo').not(this).val( $(this).val() );
    //var url = substringPreDelimiter(document.URL, "#");
    //window.history.pushState("string", "Title", url +"#" +removeChars($('input.fontdemo:first').val(), "#%"));
  });
  $('input.fontdemo').on("focusout" , function(e) { 
    //var url = substringPreDelimiter(document.URL, "#");
    //window.history.pushState("string", "Title", url +"#" +removeChars($('input.fontdemo:first').val(), "#%"));
  });
  
} // END initFontDemo


function initFontSizeSliders() {
  if ($('input.fontsize').length)  {
    fontSizeSlider = $('input.fontsize').get(0);
    fontSizeSlider_CSS = document.head.appendChild(document.createElement('style'));
    updateFontSize($('input.fontsize').attr("value"), true);
    $('input[type="range"]#fontsizeSlider').rangeslider(
      {
	polyfill: false,
	rangeClass: 'rangeslider positiv',
	fillClass: 'rangeslider__fill',
	handleClass: 'rangeslider__handle negativ',
	onSlide: function(position, value) {updateFontSize(value);}
    });  
  }
  if ($('input.flowtext-fontsize').length && !isListPage)  {
    flowtextFontSizeSlider = $('input.flowtext-fontsize').get(0);
    flowtextFontSizeSlider_CSS = document.head.appendChild(document.createElement('style'));
    updateFlowtextFontSize($('input.flowtext-fontsize').attr("value"), true);  
    $('input[type="range"]#flowtextFontsizeSlider').rangeslider(
      {
	polyfill: false,
	rangeClass: 'rangeslider positiv',
	fillClass: 'rangeslider__fill',
	handleClass: 'rangeslider__handle negativ',
	onSlide: function(position, value) {updateFlowtextFontSize(value);}
    });  
  }
} // END initFontSizeSliders


function initFlowVariants() {
//   if ($('input.flowtext-fontsize').length && !isListPage)  {
    var tmp;
    $('.flowfontvariant').on("click", function(e) {
      
      if($(e.target).parent().attr('id') === 'flowFontSelectL') {
	if(e.target.id === 'next') {
	  flowFontSelectL += 1;
	} else if(e.target.id === 'prev') {
	  flowFontSelectL -= 1;
	} else {
	    return;
	}
	if(flowFontSelectL >= fontstyles.length) flowFontSelectL = 0;
	if(flowFontSelectL < 0) flowFontSelectL = fontstyles.length-1;
			    
	tmp = flowFontSelectL;
	
      } else if($(e.target).parent().attr('id') === 'flowFontSelectR') {
	if(e.target.id === 'next') {
	  flowFontSelectR += 1;
	} else if(e.target.id === 'prev') {
	  flowFontSelectR -= 1;
	} else {
	    return;
	}
	if(flowFontSelectR >= fontstyles.length) flowFontSelectR = 0;
	if(flowFontSelectR < 0) flowFontSelectR = fontstyles.length-1;
			    
	tmp = flowFontSelectR;
	
      } else {
	  return;
      }
			    
      $(e.target).parent().css("font-family", fontstyles[tmp]);
      $(e.target).parent().children('#label').html(fontstyles[tmp]);
    }); 
//   }
} // END initFlowVariants


function checkURL() {
  orgDemoText = $('input.fontdemo:first').val();
  var url = substringPostDelimiter(document.URL, "#");
  if(url != null) {
    $('input.fontdemo').val( removeChars(urldecode(url), "#%") );
    $('#resetDemoText').show();
    demoTextUnchanged = false;
  }  
}


function bindLinks() {
  $('a.intern').on( "click", function(e) {
    if(!demoTextUnchanged) {
      var url = substringPreDelimiter($(this).attr('href'), "#");
      $(this).attr('href',  url.concat("#" +removeChars($('input.fontdemo:first').val(), "#%")) );  
    }
  });
}




// HANDLERS ==========================================================================


function updateFontSize(size, force) {
  fontSizeSlider_CSS.innerHTML = fontSizeSlider_classToChange + '{font-size:' + size + 'px}';
  if (force) fontSizeSlider.value = size;
  sizeToHeight = +size +(size/4) + 24;
  $('.accordion-section-content.open').css("height", "" +sizeToHeight +"px");
  $('.accordion-section-content:not(.open) input.fontdemo').css("margin-top", "" +-(size/2) +"px"); 
  $('.accordion-section-content.open input.fontdemo').css("margin-top", "" +((15)) +"px"); 
  $('.sliderLabel#fontsizeSlider').html(size +" px");
}

function updateFlowtextFontSize(size, force) {
  flowtextFontSizeSlider_CSS.innerHTML = flowtextFontSizeSlider_classToChange + '{font-size:' + size + 'px}';
  if (force) flowtextFontSizeSlider.value = size;
  $('.sliderLabel#flowtextFontsizeSlider').html(size +" px");
}

function close_accordion_section(elem) {
  var currentAttrValue = $(elem).attr('id');
  hh = $('input.fontsize').val();
  t = (hh/4) + hh;

  $(elem).removeClass('active');
  $('.accordion '+ currentAttrValue).removeClass('open');
  $('.accordion '+ currentAttrValue)
    .animate({ "height": accTitlebarHeight +"px" }, "fast" );
  $('.accordion '+ currentAttrValue +' input')
    .animate({ "margin-top":  +-(hh/2)+"px" }, "fast" );
}

function open_accordion_section(elem) {    
  var currentAttrValue = $(elem).attr('id');
  hh = parseInt($('input.fontsize').val());
  t = (hh/4) + hh;
  
  $(elem).addClass('active');
  $('.accordion '+ currentAttrValue)
    .addClass('open')
    .animate({ "height": "+=" +t +"px" }, "fast" );
  $('.accordion '+ currentAttrValue +' input')
    .animate({ "margin-top":  +margintop+"px" }, "fast" );
}

function resetDemoText() {
    $('input.fontdemo').each(function(index){
      $( this ).val( $( this ).attr('org'));
    });
  //$('input.fontdemo').val(orgDemoText);
  demoTextUnchanged = true;
  //var url = substringPreDelimiter(document.URL, "#");
  //window.history.pushState("string", "Title", url);
  $('#resetDemoText').hide();
}




// UTIL ==============================================================================


function substringPreDelimiter(str, del) {
   var j = str.indexOf(del);
    if(j != -1) {
      str = str.substring(0, j);
    } 
    return str;
}

function substringPostDelimiter(str, del) {
    var i = str.indexOf(del);
    if(i != -1) {
      if(str.length > (i+1)) {
        str = str.substring(i+1, str.length);
      }
      return str; 
    }
    return null;
}

function removeChars(str, chars) {
  chars = chars.replace(/[\[\](){}?*+\^$\\.|\-]/g, "\\$&");
  return str.replace( new RegExp( "[" + chars + "]", "g"), '' ); 
}

function urldecode(str) {
    return decodeURIComponent((str+'').replace(/\+/g, '%20'));
}