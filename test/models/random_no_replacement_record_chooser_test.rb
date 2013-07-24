# -*- encoding : utf-8 -*-
require 'test_helper'

class RandomNoReplacementRecordChooserTest < ActiveSupport::TestCase
  def setup
    @survey = surveys(:test)
    @all_questions = @survey.survey_questions
    @times_to_try_random_things = 10 # Yes this is janky
  end

  test "it should set all ids when empty" do
    all_ids = @all_questions.pluck :id
    chooser = RandomNoReplacementRecordChooser.new(@all_questions, [])
    assert_equal all_ids, chooser.unused_id_list
  end


  test "it should draw a question" do
    chooser = RandomNoReplacementRecordChooser.new(@all_questions)
    q = chooser.choose
    assert_includes @all_questions, q
  end

  test "it should draw all questions" do
    @times_to_try_random_things.times do
      chooser = RandomNoReplacementRecordChooser.new(@all_questions)
      chosen = (0...@all_questions.count).map {|i|
        chooser.choose
      }.uniq
      assert_equal chosen.length, @all_questions.count
    end
  end

  test "it will draw more questions" do
    chooser = RandomNoReplacementRecordChooser.new(@all_questions)
    chosen = (0...(@all_questions.count+1)).map {|i|
      chooser.choose
    }
    assert_equal (@all_questions.count+1), chosen.size
  end

end
