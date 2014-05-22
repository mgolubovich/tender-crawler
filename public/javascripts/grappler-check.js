(function($) {
  var checkButton = $("#grappler-check");
  var url = "/sources/edit/$source_id/selector/$selector_id/check";
  var source_id = checkButton.attr("data-source-id");
  var selector_id = checkButton.attr("data-selector-id");
  var entity_id = $("#entity_id");

  checkButton.click(function (e) {
    e.preventDefault();

    url = url.replace("$source_id", source_id);
    url = url.replace("$selector_id", selector_id);

    if (entity_id.val().length > 0) {
      url = url + '?entity_id=' + entity_id.val();
    }

    $.get(url, function(data) {
      alert(data.grappled_value);
    }, "json");
  });
})(jQuery);