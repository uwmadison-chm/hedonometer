# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ = jQuery

$ ->
    $('#send_code_button')
        .prop('type', 'button')
        .click ->
            the_button = $(this)
            the_button.siblings("span").remove()
            my_form = $(this).parents('form')
            form_data = my_form.serialize()
            form_data += '&send_code=1'
            req = $.post(
                my_form.prop('action'),
                form_data)
            .done ->
               the_button.after('<span class="status success">Sent!</span>')
            .fail ->
                the_button.after('<span class="status failure">Not found</span>')