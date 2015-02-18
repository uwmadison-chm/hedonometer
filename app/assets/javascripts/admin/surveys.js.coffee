$ ->
  update_twilio_status = (
    url, sid_field, token_field, status_element, phone_number_field) ->

    sid = sid_field.val().trim()
    token = token_field.val().trim()
    if sid != '' and token != ''
      check_twilio_account(url, sid, token, status_element, phone_number_field)
    else
      status_element
        .removeClass()
        .data('status', '')
        .text("")
      phone_number_field.autocomplete({source: []})

  check_twilio_account = (
    url, sid, token, status_element, phone_number_field) ->

    $.ajax
      url: url
      type: 'GET'
      data:
        sid: sid
        auth_token: token
      success: (data, status, response) ->
        result = data.status
        numbers = data.numbers.available.map (num) ->
          num.phone_number_human
        phone_number_field.autocomplete({source: numbers})
        status_element
          .removeClass()
          .addClass(result + " status-light")
          .data('status', result)
          .text(result)
      error: (req, status, exc) ->
        phone_number_field.autocomplete({source: []})
        status_element
          .removeClass()
          .addClass('error status-light')
          .data('status', 'error')
          .text('error')
      dataType: 'json'

  $('input[data-twilio-account-check-url]').each (i, element) ->
    e = $(element)
    url = e.data('twilio-account-check-url')
    sid_field = $(e.data('sid-field'))
    token_field = $(e.data('token-field'))
    status_element = $(e.data('status-element'))
    phone_number_field = $(e.data('phone-number-field'))
    update_twilio_status(
      url, sid_field, token_field, status_element, phone_number_field)
    $(sid_field).change ->
      update_twilio_status(
        url, sid_field, token_field, status_element, phone_number_field)
    $(token_field).change ->
      update_twilio_status(
        url, sid_field, token_field, status_element, phone_number_field)

