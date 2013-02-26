# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

px_per_minute = 1

sample_count = ->
  $('#num_samples').val() - 1

day_len_minutes = -> 
  $('#mean_time').val() * sample_count() + $('#time_range').val()*2
  
day_width_px = ->
  day_len_minutes() * px_per_minute + 'px'

set_demo_width = ->
  $('#demo').css('width', day_width_px())

draw_sampling_periods = ->
  demo = $('#demo')
  periods = sample_count();
  width = $('#time_range').val()* 2 * px_per_minute + 'px'
  i = 0
  while i < periods+1
    start_time = i * $('#mean_time').val()
    start_px = start_time * px_per_minute + 'px'
    $('<div class="sp"></div>').appendTo(demo).css
      width: width,
      left: start_px
    i++


draw_hours = ->
  demo = $('#demo')
  cur_min = 0
  i = 0
  hour_width = 60 * px_per_minute + 'px'
  demo.empty()
  
  while cur_min < day_len_minutes()
    left_pos = 60*px_per_minute * i + 'px'
    $('<div class="hour"></div>').appendTo(demo).css 
      width: hour_width
      left: left_pos
    cur_min += 60
    i += 1

do_demo = ->
  set_demo_width()
  draw_hours()
  draw_sampling_periods()
  

jQuery ->
  do_demo()
  $('input').on('change', -> 
    do_demo()
  )
