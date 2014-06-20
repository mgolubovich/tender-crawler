// Sortable rows
$('.sorted_table').sortable({
  containerSelector: 'table',
  itemPath: '> tbody',
  itemSelector: 'tr',
  placeholder: '<tr class="placeholder"/>'
})

var selectors = $('.movable');
selectors.drop(function () {
    var index = 0;
    selectors.each(function () {
        $(this).child('input').val(index);
        $(this).child('.priority-value').html(index);
        index++;
    });
});
