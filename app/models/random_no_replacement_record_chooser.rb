# -*- encoding : utf-8 -*-
class RandomNoReplacementRecordChooser
  attr_reader :record_set, :unused_ids
  def initialize(record_set, unused_ids=[])
    @record_set = record_set
    @unused_ids = unused_ids
    allow_all_ids_if_empty!
  end

  def choose
    id_to_choose = @unused_ids.sample
    @unused_ids.delete id_to_choose
    allow_all_ids_if_empty!
    @record_set.find id_to_choose
  end

  def serialize_state
    {
      type: self.class.to_s,
      unused_ids: self.unused_ids
    }
  end

  private
  def allow_all_ids_if_empty!
    if @unused_ids.empty?
      @unused_ids = @record_set.pluck :id
    end
  end
end
