(function() {
  var day_len_minutes, day_width_px, do_demo, draw_hours, draw_sampling_periods, px_per_minute, sample_count, set_demo_width;


  px_per_minute = 1;

  sample_count = function() {
    return $('#num_samples').val() - 1;
  };

  day_len_minutes = function() {
    return $('#mean_time').val() * sample_count() + $('#time_range').val() * 2;
  };

  day_width_px = function() {
    return day_len_minutes() * px_per_minute + 'px';
  };

  set_demo_width = function() {
    return $('#demo').css('width', day_width_px());
  };

  draw_sampling_periods = function() {
    var demo, i, periods, start_px, start_time, width, _results;
    demo = $('#demo');
    periods = sample_count();
    width = $('#time_range').val() * 2 * px_per_minute + 'px';
    i = 0;
    _results = [];
    while (i < periods + 1) {
      start_time = i * $('#mean_time').val();
      start_px = start_time * px_per_minute + 'px';
      $('<div class="sp"></div>').appendTo(demo).css({
        width: width,
        left: start_px
      });
      _results.push(i++);
    }
    return _results;
  };

  draw_hours = function() {
    var cur_min, demo, hour_width, i, left_pos, _results;
    demo = $('#demo');
    cur_min = 0;
    i = 0;
    hour_width = 60 * px_per_minute + 'px';
    demo.empty();
    _results = [];
    while (cur_min < day_len_minutes()) {
      left_pos = 60 * px_per_minute * i + 'px';
      $('<div class="hour"></div>').appendTo(demo).css({
        width: hour_width,
        left: left_pos
      });
      cur_min += 60;
      _results.push(i += 1);
    }
    return _results;
  };

  do_demo = function() {
    set_demo_width();
    draw_hours();
    return draw_sampling_periods();
  };

  jQuery(function() {
    do_demo();
    return $('input').on('change', function() {
      return do_demo();
    });
  });

}).call(this);