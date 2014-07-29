(function($) {
  var reapingTypeInput = $('#cartridge_reaping_type');
  var offsetBlock = $('#list_offset');
  offsetBlock.hide();
  reapingTypeInput.change(function () {
    var currentState = $(this).val();
      if (currentState == "list") {
        offsetBlock.show("slow");
      } else {
        offsetBlock.hide("slow");
      }
  });
})(jQuery);
