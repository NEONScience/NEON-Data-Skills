(function($) {

  Drupal.behaviors.hydraLists = {
    attach: function(context, settings) {
      $(context).find('li:first-child').addClass('first').siblings('li:last-child').addClass('last');
    }
  };

})(jQuery);