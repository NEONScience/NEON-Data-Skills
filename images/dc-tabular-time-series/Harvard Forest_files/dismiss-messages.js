(function($) {

Drupal.behaviors.hydraDismissMessages = {
  attach: function(context, settings) {
    $(context).find('.messages .dismiss a').click(function() {
      $(this).parents('.messages').fadeOut();
      return false;
    });
  }
};

})(jQuery);