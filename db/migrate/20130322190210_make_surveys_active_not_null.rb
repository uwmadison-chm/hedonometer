# -*- encoding : utf-8 -*-
class MakeSurveysActiveNotNull < ActiveRecord::Migration[4.2]
  def change
    change_column :surveys, :active, :boolean, null: false, default: false
  end
end
