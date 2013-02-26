# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

px_per_minute = 2

default_start_min = 60*8

day_length_min = 60*24

day_length_px = day_length_min / px_per_minute

draw_days = (container) ->
  container.empty()

jQuery ->
  start_date = new Date()
  day_count = 3
  needed_hours = 10
  needed_minutes = needed_hours*60
  draw_days($('#days'), start_date, day_count, needed_hours)