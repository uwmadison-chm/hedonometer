# -*- encoding : utf-8 -*-
class MakeSurveysActiveNotNull < ActiveRecord::Migration
  def change
    change_column :surveys, :active, :boolean, null: false, default: false
  end
end
