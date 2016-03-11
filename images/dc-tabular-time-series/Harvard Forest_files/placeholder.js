(function($) {

  // Adds support for the HTML 5 placeholder attribute.
  
  var options = {
  };

  $(document).ready(
    function() {
      try {
        $.getScript('/sites/all/libraries/jquery/placeholder.js',
          function() {
            $('input[type="text"], textarea').filter('[placeholder]').placeholder(options);
          }
        );
      }
      catch(e) {
        console.log('placeholder failed: ' + e);
      }
    }
  );

})(jQuery);