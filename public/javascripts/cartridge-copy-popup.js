  var copyButton = $('.copy-button');
  var modalTitle = $('h4.modal-title');
  var cartridgeId = $('#cartridge_id');
  var copyRules = $('.copy-rules');
  var checkboxSelector = $('#copy_selectors');
  var checkboxRules = $('#copy_rules');
  copyButton.click(function (e) {
      modalTitle.html('Copy ' + $(this).attr('data-cart-name') + ' (' + $(this).attr('data-source-name') + ')');
      cartridgeId.val($(this).attr('data-cart-id'));
  });
  checkboxSelector.click(function () {
      var currentState = $(this).prop('checked');
      if (currentState) {
          checkboxRules.removeAttr("disabled");
          copyRules.show("slow");
      } else {
          copyRules.hide("slow");
          checkboxRules.attr("disabled", true);
      }
  });
