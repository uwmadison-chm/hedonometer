$ ->
  update_twilio_status = (url, sid_field, token_field, status_element) ->
    sid = $(sid_field).val().trim()
    token = $(token_field).val().trim()
    if sid != '' and token != ''
      check_twilio_account(url, sid, token, status_element)
    else
      $(status_element)
        .removeClass()
        .data('status', '')
        .text("")

  check_twilio_account = (url, sid, token, status_element) ->
    $.ajax
      url: url
      type: 'GET'
      data:
        sid: sid
        auth_token: token
      success: (data, status, response) ->
        result = data.status
        $(status_element)
          .removeClass()
          .addClass(result + " status-light")
          .data('status', result)
          .text(result)
      error: (req, status, exc) ->
        $(status_element)
          .removeClass()
          .addClass('error status-light')
          .data('status', 'error')
          .text('error')
      dataType: 'json'

  $('input[data-twilio-account-check-url]').each (i, element) ->
    e = $(element)
    url = e.data('twilio-account-check-url')
    sid_field = e.data('sid-field')
    token_field = e.data('token-field')
    status_element = e.data('status-element')
    update_twilio_status url, sid_field, token_field, status_element
    $(sid_field).change ->
      update_twilio_status url, sid_field, token_field, status_element
    $(token_field).change ->
      update_twilio_status url, sid_field, token_field, status_element