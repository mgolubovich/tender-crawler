(function($) {
    $('.sorted_table').sortable({
        containerSelector: 'table',
        itemPath: '> tbody',
        itemSelector: 'tr',
        placeholder: '<tr class="placeholder"/>',
        onDrop: function ($item, container, _super, event) {
            /* Default behavior, do not change */
            $item.removeClass("dragged").removeAttr("style");
            $("body").removeClass("dragging");
            var index = 0;
            $('.movable').each(function () {
                $(this).find('input').val(index);
                $(this).find('.priority-value').html(index);
                index++;
            });
            // Create data hash
            var inputs = $('.movable input');
            var data = {};
            inputs.each(function () {
              data[$(this).attr('name')] = $(this).val();
            });
            // Send to Ruby
            var cartId = $('.base-content > h1').attr('id');
            $.post( "/cartridges/priority/" + cartId + "/save", { data: data })
             .done(function() {
              var done = $('.ok')
              done.css('display', 'block');
              done.hide(3000);
               });
        }
    });
    var infoButton = $('.movable #info');
    infoButton.click(function() {
        $('.css').html($(this).attr('css'));
        $('.xpath').html($(this).attr('xpath'));
        $('.date_format').html($(this).attr('date_format'));
        $('.link_template').html($(this).attr('link_template'));
    });
})(jQuery);
