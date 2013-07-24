# -*- encoding : utf-8 -*-
class RandomNoReplacementRecordChooser
  attr_reader :record_set, :unused_id_list
  def initialize(record_set, unused_id_array=[])
    @record_set = record_set
    @unused_id_list = unused_id_array
    allow_all_ids_if_empty!
  end

  def choose
    id_to_choose = @unused_id_list.sample
    @unused_id_list.delete id_to_choose
    allow_all_ids_if_empty!
    @record_set.find id_to_choose
  end

  private
  def allow_all_ids_if_empty!
    if @unused_id_list.empty?
      @unused_id_list = @record_set.pluck :id
    end
  end
end
