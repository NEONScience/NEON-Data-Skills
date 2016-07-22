(function($) {

Drupal.behaviors.hydraModals = {
  attach: function(context, settings) {
    $(context)
    .find('a.modal:not(.with-modal)')
    .click(function() {
      try {
        // The theme needs to be notified that it's displaying in a modal. template.php
        // expects this if $_REQUEST['modal'] is set.
        this.href += this.search.length > 0 ? '&' : '?';
        this.href += 'modal=1';

        // Allow the width and height to be set with data-width and data-height HTML5 attributes.
        var w = $(this).data('width') || 750;
        var h = $(this).data('height') || 450;

        // Create an <iframe>, and invoke SimpleModal on it.
        var $frame = $('<iframe></iframe>').attr({ width: w, height: h, frameborder: 0, src: this.href });
        $frame.modal({
          opacity: 80,
          overlayId: 'modal-overlay',
          overlayCss: { backgroundColor: '#000' },
          containerId: 'modal-container',
          containerCss: {},
          dataId: 'modal-data',
          minHeight: h, // @TODO: Should these be maxWidth and maxHeight instead?
          minWidth: w,
          zIndex: 2000,
          closeHTML: '<a href="#"><img src="/sites/default/themes/forest/images/close.png" alt="Close" /></a>',
          closeClass: 'modal-exit',
          overlayClose: true // Clicking on the overlay will close the modal
        });
        return false; // Don't follow the link
      } catch(error) {
        return true;  // Normal link behavior if modal couldn't open
      }
    })
    .addClass('with-modal');
  }
}

})(jQuery);