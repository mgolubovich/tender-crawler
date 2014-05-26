(function($) {
  var checkButton = $("#grappler-check");
  var url_template = "/cartridges/edit/$cartridge_id/selector/$selector_id/check?entity_id=";
  var cartridge_id = checkButton.attr("data-cartridge-id");
  var selector_id = checkButton.attr("data-selector-id");
  var entity_id = $("#entity_id");

  checkButton.click(function (e) {
    e.preventDefault();

    var url = url_template + entity_id.val();
    url = url.replace("$cartridge_id", cartridge_id);
    url = url.replace("$selector_id", selector_id);

    $.get(url, function(data) {
      alert(data.grappled_value);
    }, "json");
  });
})(jQuery);