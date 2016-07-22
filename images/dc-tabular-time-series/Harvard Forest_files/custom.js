(function ($) {

  Drupal.behaviors.hydra = {
    attach: function(context, settings) {
      // The FAQ page should have a hide/reveal mechanism for each FAQ. Since it's a view
      // with Ajax enabled, this needs to be a behaviour.
        $('.view-faqs', context).find('.views-field-title a').click(function() {
          $(this).parents('.views-field').toggleClass('visible').siblings('.views-field-body').slideToggle();
          return false;
        });
      
      //Rounded COrners
      try { // w/o try/catch, these were breaking javascript in filefield_imce popups.
  			$('#nice-menu-1 li a.level-1').corner('6px');
  			$('.sidebar .promotion').corner('10px');
			}
			catch(err) {}
			
		  $('.xpandable').each(function() {
			  $(this)
			    .click(function() {
			      $(this).toggleClass('open').next('.xpand').slideToggle();
			    })
			    .nextUntil('.xpandable, .non-xpandable')
			    .wrapAll('<div class="xpand"></div>');
			});
    }
  };

  $(document).ready(
    function() {
      $('#block-views-front-page-slideshow-block .view-content').cycle({
        fx: 'scrollHorz', 
				prev: '#prev1', 
				next: '#next1', 
				timeout: 10000,
				speed: 1800,
				fx: 'fade'
      });
      $('#block-views-webcams-block .views-field-field-webcam-url a').data({ width: 900, height: 600 });
      
      $('#block-lunchbox-archive .content .item-list h3').click(function() {
        $('#block-lunchbox-archive .content .item-list ul:visible').removeClass('expanded').slideUp();
        $(this).addClass('expanded').next('ul').slideDown();
      });
      if(location.hash.length > 0) {
        $('#block-lunchbox-archive .content .item-list ul').hide().filter( location.hash.replace('y', '') ).show();
      }
        
      $('#block-lunchbox-blog-dates .content .item-list h3').click(function() {
        $('#block-lunchbox-blog-dates .content .item-list ul:visible').removeClass('expanded').slideUp();
        $(this).addClass('expanded').next('ul').slideDown();
      });
      if(location.hash.length > 0) {
        $('#block-lunchbox-blog-dates .content .item-list ul').hide().filter( location.hash.replace('y', '') ).show();
      }
      
    }
  );

})(jQuery);
