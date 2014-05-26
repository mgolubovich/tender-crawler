(function($) {
  var checkButton = $("#grappler-check");
  var url = "/cartridges/edit/$cartridge_id/selector/$selector_id/check";
  var cartridge_id = checkButton.attr("data-cartridge-id");
  var selector_id = checkButton.attr("data-selector-id");
  var entity_id = $("#entity_id");

  checkButton.click(function (e) {
    e.preventDefault();

    url = url.replace("$source_id", cartridge_id);
    url = url.replace("$cartridge_id", selector_id);

    if (entity_id.val().length > 0) {
      url = url + '?entity_id=' + entity_id.val();
    }

    $.get(url, function(data) {
      alert(data.grappled_value);
    }, "json");
  });
})(jQuery);