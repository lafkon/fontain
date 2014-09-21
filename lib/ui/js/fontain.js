// needs to be set in HEAD section of pages
// var isListPage = true;

var accTitlebarHeight = 24;
var of = 1;
var margintop = 15;

var fontSize;
var fontSizeOrg = 120;
var fontSizeSlider;
var fontSizeSlider_CSS;
var fontSizeSlider_classToChange  = 'input.fontdemo';
var flowtextFontSizeSlider;
var flowtextFontSizeSlider_CSS;
var flowtextFontSizeSlider_classToChange  = 'div.flowtext';

var demoTextUnchanged = true;
// var orgDemoText;
var showmoreButton;
var windowscrolltop = 0;
var ticking = false;

var sliderDiv; 
var sliderDivTop;
var sliderHeight;
var resetTextButton; 
var resetTextButtonLabel; 
var buttonOffset = 25;

var typeclassDefText;
var typeclassAllText;

var fontlogLoaded = false;

// INIT ==============================================================================


$(document).ready(function() {
  
  //fallback for old browser without requestAnimationFrame-Support
  if ( !window.requestAnimationFrame ) {
    window.requestAnimationFrame = ( function() {
      return window.webkitRequestAnimationFrame ||
      window.mozRequestAnimationFrame ||
      window.oRequestAnimationFrame ||
      window.msRequestAnimationFrame ||
      function( /* function FrameRequestCallback */ callback, /* DOMElement Element */ element ) {
	      window.setTimeout( callback, 1000 / 60 );
      };
    } )();
  }  
  
  $(window).scroll(function () {
    windowscrolltop = $(window).scrollTop(); 
    requestTick();
  });

  $('.jsonly').css("display", "inline");
  $('.jsonly').css("visibility", "visible");

  checkURL();
  bindLinks();
  
  initSortable();
  initFontDemo();
  initFontSizeSliders();
  initFlowVariants();

  initStaticElements();
  
  if(isListPage) {
    initTypeClassSelector();
  }
  if(!isListPage) {
    initAjaxLinks();
  }
  
  //expand first/all not-excluded fontdemo
  if(!isListPage) {
    $('.accordion-section').not('.excluded').first().children('.accordion-section-header').children('.accordion-section-title').trigger("click");
  } else if(isListPage) {
    $('.accordion-section').children('.accordion-section-header').children('.accordion-section-title').trigger("click");
    $('.accordion-section').children('.accordion-section-header').children('.accordion-section-title').unbind("click", handleAccordionClick);
  }
 
}); // END document.ready



// GLOBAL ==============================================================================

function requestTick() {
  if(!ticking) {
    requestAnimationFrame(update);
  }
  ticking = true;
}


 //called onScroll
 function update() {
   ticking = false;

  if(isListPage) {   
    top = sliderDivTop;
    if(windowscrolltop > sliderDivTop ) { 
      sliderDiv.addClass('fixed'); 
    }  
    else if(windowscrolltop <= sliderDivTop && sliderDiv.hasClass('fixed')) { 
      sliderDiv.removeClass('fixed'); 
    }
    
    if(windowscrolltop > (sliderDivTop + buttonOffset)) {
      resetTextButton.css( {'top' : windowscrolltop-sliderDivTop -buttonOffset +'px'} );
      resetTextButtonLabel.css( {'top' : windowscrolltop-sliderDivTop -buttonOffset +5 +'px'} );
    }    
    else if(windowscrolltop <= (sliderDivTop + buttonOffset) ) {
      resetTextButton.css( {'top' : 0 +'px'} );
      resetTextButtonLabel.css( {'top' : 5 +'px'} );
    }
  } 
  else {
    if(windowscrolltop > 20) {
      $(".row#menu").addClass('fixed');
      $("div.menu").children().not(":first").css('position', 'relative');
      $("div.menu").children().not(":first").css("top", -(windowscrolltop) +"px");
    } else{
      $("div.menu").children().not(":first").css("top", -(windowscrolltop) +"px");
      $("div.menu").children().not(":first").css('position', 'relative');
      $(".row#menu").removeClass('fixed');
      
    }
  }   
 }
 
// INIT ==============================================================================





  function initAjaxLinks() {
    $("#ajax").on("click", function(e) {
    var node = $(e.target);
    var contentnode =  node.next();
    var buttonText = node.html();
    var linkedfile = node[0].href;
    
    
    if(linkedfile.substring(0, 7) != "file://") {
	if(!fontlogLoaded) {
	  node.html("Loading")
	  jQuery.get(linkedfile, function(data) {
	    fontlogLoaded = true;
	    contentnode.html(data);
	    node.html(buttonText);
	    contentnode.stop( false, true ).toggle("blind",{}, 400);
	  });
	} else {
	  contentnode.stop( false, true ).toggle("blind",{}, 400); 
	}
	e.preventDefault(); 
      }
    }); 
    $("#ajax").next().hide();  
  }


  function initTypeClassSelector() {
    typeclassDefText = $("#typeclass").html();
    typeclassAllText = $("#typeclasses li a").first().html()
    
    $("#typeclasses > li > a").click(function(e) {
	var curclass = $(this).html();
	var reset = false;
	
	  //change dropdown-menu
	  if( ($(e.target).hasClass("selected")) || (curclass == typeclassAllText) ) {
	    $("#typeclasses li a.selected").removeClass("selected");
	    $("#typeclass" ).removeClass("selected");
	    reset = true;
	  } else {
	    $( "#typeclasses li a.selected").removeClass("selected");
	    $(e.target).addClass("selected");
	    $("#typeclass" ).addClass("selected");	    
	  }
	
	//reset ui to no selection
	if(reset) {
	   $( ".accordion-section-title.marked" ).removeClass("marked");
	   $( ".accordion-section-title:not(.active)" ).each(function( index ) {
	      open_accordion_section($(this));
	   });
	   $("#typeclass").html(typeclassDefText);
	} 
	//show selected items, hide others
	else {
	  $( ".accordion-section-title:not(.active)[data-typeclass~='" +curclass +"']" ).each(function( index ) {
	    open_accordion_section($(this));
	  });
	  $( ".accordion-section-title.active:not([data-typeclass~='" +curclass +"'])" ).each(function( index ) {
	    $(this).removeClass("marked");
	    close_accordion_section($(this));
	  });
 	  
	  //add marked, also for ones not being opened, cause already open
	  $( ".accordion-section-title.active").addClass("marked");
	  
	  $("#typeclass").html(curclass);
	  
	}
	e.preventDefault();
    });
  
  }

 function initStaticElements() {
  if(isListPage) {
    sliderDiv = $("#slider");
    sliderDivTop = sliderDiv.offset().top;
    sliderHeight = sliderDiv.outerHeight();
    
    sliderDiv.css( {'margin-bottom' : -sliderHeight +'px'} );
    
    $( window ).resize( function() {
      sliderHeight = sliderDiv.outerHeight();
      sliderDiv.css( {'margin-bottom' : -sliderHeight +'px'} );
    });
  }
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
    cursor: "move"
  });
  
  $( "#sortable" ).sortable( {
    sort: function(event, ui) {  ui.helper.css({'top' : ui.position.top + windowscrolltop + 'px'}); },
    change: function(event, ui) {  windowscrolltop = $(window).scrollTop(); }
  }); 
} // END initSortable


function initFontDemo() {
  resetTextButton = $("#resetDemoText");
  resetTextButtonLabel = $("#resetDemoTextLabel");
  $('input.fontdemo').css("margin-top", "-60px"); 
  $('.accordion-section-content').css({
      "height": "24px",
      "margin-top": "-24px"
  });
  
  //========== show/hide excluded fonts
  if ($('a.fontdemo-showmore').length)  {
    $('a.fontdemo-showmore').click(function(e) {
      if($('.excluded:first').is(":hidden"))  {
	showmoreButton = $(e.target).html();
	$('.excluded').show('fast');   
	$(e.target).html("show less");
      } else if($('.excluded:first').is(":visible")) {
	$('.excluded').hide('fast'); 
	$(e.target).html(showmoreButton);
      } 
      $( "#sortable" ).sortable( "refreshPositions" );
      e.preventDefault();
    });   
  }

  //========== reset textfields to original values
  resetTextButton.click(function(e) {
    if(!demoTextUnchanged) {
      resetDemoText();
    }
  });

  //========== expand/collapse accordion-elements
    $('.accordion-section-title').click(handleAccordionClick);
  
  //========== change inputtext on all inputs
  $('input.fontdemo').on("input" , function(e) {
    if(demoTextUnchanged) {
      resetTextButton.show();
      resetTextButtonLabel.show();
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


function handleAccordionClick(e) {
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
} // END handleAccordionClick


function initFontSizeSliders() {
  if ($('input.fontsize').length)  {
    fontSizeSlider = $('input.fontsize').get(0);
    fontSizeSlider_CSS = document.head.appendChild(document.createElement('style'));
//     fontSizeOrg = $('input.fontsize').attr("value");
//     if(!fontSize) {
//       fontSize = fontSizeOrg;
//     }
    updateFontSize($('input.fontsize').attr("value"), true);
//     updateFontSize(fontSize, true);
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
  if ($('input.flowtext-fontsize').length && !isListPage)  {
    var tmp;
    
    if(fontstyles.length <= 1) {
      $("#prev").css("display", "none");
      $("#next").css("display", "none");
      return;
    }
    
    $('.flowfontvariant').on("click", function(e) {
      if($(e.target).parent().attr('id') === 'flowFontSelectR') {
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
			    
      $(e.target).parent().children('.flowtext').first().css("font-family", fontstyles[tmp]);
      $(e.target).parent().children('#label').html(fontstyles[tmp]);
    }); 
  }
} // END initFlowVariants


function checkURL() {
  var url = substringPostDelimiter(document.URL, "#", true);
  var fsz = substringPostDelimiter(document.URL, "@");
  if(fsz != null) {
    if($.isNumeric(fsz)) {
      $('input.fontsize').attr("value",  parseInt(fsz));
      url = substringPreDelimiter(url, "@");
    }
  }
  if(url != null && url != "") {
    $('input.fontdemo').val( removeChars(urldecode(url), "#%") );
    $('#resetDemoText').show();
    $('#resetDemoTextLabel').show();
    demoTextUnchanged = false;
  }
}


function bindLinks() {
  $('a.intern').on( "click", function(e) {
    var url = substringPreDelimiter($(this).attr('href'), "#");
    var urlsize = "";
     if(fontSizeOrg != $('input.fontsize').attr("value")) {
	urlsize = "@" + $('input.fontsize').attr("value");
     }
    
    //input has occured
    if(!demoTextUnchanged) {
      $(this).attr('href',  url.concat("#" +removeChars($('input.fontdemo:first').val(), "#%")) +urlsize );  
    }
    //text came with url, but was reset by resetDemoText-Button
    else if(demoTextUnchanged && (document.URL.indexOf("#") != -1)) {
      if(urlsize.length > 0) {
	$(this).attr('href', url +"#" +urlsize);
      } else {
	$(this).attr('href', url);
      }
    }
    //only fontsize changed
    else if(demoTextUnchanged && urlsize.length > 0) {
       $(this).attr('href', url +"#" +urlsize);
      
    }
  });
}




// HANDLERS ==========================================================================


function updateFontSize(size, force) {
  $('input.fontsize').attr("value",  size);
  fontSizeSlider_CSS.innerHTML = fontSizeSlider_classToChange + '{font-size:' + size + 'px}';
  if (force) fontSizeSlider.value = size;
  sizeToHeight = +size +(size/4) + 24;
  $('.accordion-section-content.open').css("height", "" +sizeToHeight +"px");
  $('.accordion-section-content:not(.open) input.fontdemo').css("margin-top", "" +-(size/2) +"px"); 
  $('.accordion-section-content.open input.fontdemo').css("margin-top", "" +((15)) +"px"); 
  $('.sliderLabel#fontsizeSliderLabel').html(size +" px");
}

function updateFlowtextFontSize(size, force) {
  flowtextFontSizeSlider_CSS.innerHTML = flowtextFontSizeSlider_classToChange + '{font-size:' + size + 'px}';
  if (force) flowtextFontSizeSlider.value = size;
  $('.sliderLabel#flowtextFontsizeSliderLabel').html(size +" px");
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
      $( this ).val( $( this ).attr('data-org'));
    });
  demoTextUnchanged = true;
//   if(document.URL.indexOf("#") != -1) {
//     var url = substringPreDelimiter(document.URL, "#");
//     window.history.pushState("string", "Title", url);
//   }
  resetTextButton.hide();
  resetTextButtonLabel.hide();
}




// UTIL ==============================================================================


function substringPreDelimiter(str, del, firstOcc) {
  var j;
  if(firstOcc) {
    j = str.indexOf(del);
  } else {
    j = str.lastIndexOf(del);
  }  
  if(j != -1) {
    str = str.substring(0, j);
  } 
  return str;
}

function substringPostDelimiter(str, del, firstOcc) {
  var i;
  if(firstOcc) {
    i = str.indexOf(del);
  } else {
    i = str.lastIndexOf(del);
  }
  if(i != -1) {
    if(str.length > (i+1)) {
      return str.substring(i+1, str.length);
    }
  }
  return null;
}

// function substringPostDelimiter(str, del, firstOcc) {
//   console.log(firstOcc);
//     var i = str.indexOf(del);
//     if(i != -1) {
//       if(str.length > (i+1)) {
//         str = str.substring(i+1, str.length);
//       }
//       return str; 
//     }
//     return null;
// }

function removeChars(str, chars) {
  chars = chars.replace(/[\[\](){}?*+\^$\\.|\-]/g, "\\$&");
  return str.replace( new RegExp( "[" + chars + "]", "g"), '' ); 
}

function urldecode(str) {
    return decodeURIComponent((str+'').replace(/\+/g, '%20'));
}