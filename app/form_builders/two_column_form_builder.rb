# -*- encoding : utf-8 -*-

class TwoColumnFormBuilder < ActionView::Helpers::FormBuilder
  # Return something like:
  # <div class="line">
  # <div class="col1"><label for="something[foo]">Label text</label></div>
  # <div class="col2"><input type= ... /></div>
  # <div class="feedback"><span class="error">Field errors</span></div>
  # </div>

  def left_label(attribute, field_content, label_content, options={})
    @template.content_tag(:div, class: "line") do
      @template.content_tag(:div, label(attribute, label_content), class: "col1")+
      @template.content_tag(:div, field_content, class: "col2")+
      @template.content_tag(:div, field_errors(attribute), class: "feedback")
    end
  end

  # Just like left_label, except the label and content are reversed -- for
  # checkboxes and the like.
  def right_label(attribute, field_content, label_content, options={})
    @template.content_tag(:div, class: "line") do
      @template.content_tag(:div, field_content, class: "col1")+
      @template.content_tag(:div, label(attribute, label_content), class: "col2")+
      @template.content_tag(:div, field_errors(attribute), class: "feedback")
    end
  end

  left_labeled_fields = [
    :text_field, :email_field, :number_field, :password_field, :file_field,
    :color_field, :search_field, :telephone_field, :phone_field,
    :date_field, :time_field, :datetime_field, :datetime_local_field,
    :month_field, :week_field, :url_field, :range_field, :text_area
  ]
  left_labeled_fields.each do |f|
    define_method f do |attribute, options = {}|
      label_content = options.delete :label
      follow_content = options.delete :follow_field_with
      field_content = super(attribute, options) + follow_content
      left_label attribute, field_content, label_content, options
    end
  end

  def select(attribute, list, options={}, html_options={})
      label_content = options.delete :label
      follow_content = options.delete :follow_field_with
      field_content = super(attribute, list, options, html_options) + follow_content
      left_label attribute, field_content, label_content
  end

  def time_zone_select(attribute, priority_zones=nil, options={}, html_options={})
      label_content = options.delete :label
      follow_content = options.delete :follow_field_with
      field_content = super(attribute, priority_zones, options) + follow_content
      left_label attribute, field_content, label_content
  end

  def check_box(attribute, options={})
    label_content = options.delete(:label)
    right_label attribute, super, label_content, options
  end

  def field_errors(attribute, options={})
    errors = object.errors[attribute]
    return '' if errors.empty?
    error_str = object.errors[attribute].join(", ").capitalize
    @template.content_tag(:span, error_str, class: "error")
  end

  def right_content(value, options={})
    @template.content_tag(:div, class: "line") do

      @template.content_tag(:div, "&nbsp;", {class: "col1"}, false) +
      @template.content_tag(:div, {class: "col2"}) do
        value
      end

    end
  end

  def submit(value, options = {})
    right_content(@template.submit_tag(value, options))
  end
end
