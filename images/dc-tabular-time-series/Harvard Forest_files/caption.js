(function ($, Drupal, window, document, undefined) {  
  
  /**
   * Adds captions to images that have alt tags that match [.*]
   * @argument {img} The image node.
   */
  function hydraCaptions(img) {
    if (typeof img.hydraCaptionsFired !== 'undefined') {
      return;
    }
   
    var $img = $(img);
    var align = $img.css('float');

    var s = img.alt.indexOf('[');
    var e = img.alt.lastIndexOf(']');
    if(s > -1 && e > s) {
      var caption = img.alt.substring(++s, e);
    }
    
    if(align === 'left' || align === 'right' || typeof caption !== "undefined") {
      $img.css('float', 'none').wrap('<div class="picture"></div>').parent().addClass('picture-' + align).width(img.width);
      if(caption) {
        $img.after('<span class="caption"></span>').next().html(caption).parent().addClass('with-caption');
      }
    }
    
    img.hydraCaptionsFired = true;
  }
  
  Drupal.behaviors.hydraCaptions = {
    attach: function(context, settings) {
      $(context).find('img').each( function() {
        $(this).load(hydraCaptions(this));
        //Halt on broken images
        $(this).error(function() {
          this.hydraCaptionsFired = true;
        });
      });// end of iterator
    }
  };
  
  //The load event is unreliable and is not firing in chrome when expected.
  //So we're falling back to window load as well.
  $(window).load( function() {
    $('img').each(function() {
      hydraCaptions(this);
    });
  });

})(jQuery, Drupal, this, this.document);
