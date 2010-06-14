/*
 * 	sDrop 0.1 - jQuery plugin
 *	written by Martin Srank
 *	http://labs.smasty.net/jquery/sdrop/
 *
 *	Copyright (c) 2009 Alen Grakalic (http://cssglobe.com)
 *	Dual licensed under the MIT (MIT-LICENSE.txt)
 *	and GPL (GPL-LICENSE.txt) licenses.
 *
 *	Built for jQuery library
 *	http://jquery.com
 *
 */
(function($) {
  $.fn.sDrop = function(options) {

  var opts = $.extend({}, $.fn.sDrop.defaults, options);

    return this.each(function() {
      $('body').addClass('js').removeClass('nojs');
      this.items=$(this).children('ul').children('li');
      $(this).children('ul').children('li').children('ul').hide();
      $(this.items).hover(function(){
        $(this).toggleClass('hover');
        if(opts.animate){
          $(this).children('ul').slideToggle(opts.duration);
        }
        else{
          $(this).children('ul').toggle();
        }
      });
    });
  }
   $.fn.sDrop.defaults = {animate: false,duration: 200}
})(jQuery);
