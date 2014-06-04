var button = $('.btn.btn-primary.btn-lg');
var form = $('.form-horizontal');
var fieldDiv = $('.col-md-5');
var field = $('#selector_value');

button.click(function (e) {
        e.preventDefault();
        if (field.val().length > 0)
            form.submit();
        else {
            fieldDiv.addClass('has-error');
            field.attr('placeholder', 'value_type забыл!')
            alert('govno!')
        }
    }
