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
        }
    });
})(jQuery);
