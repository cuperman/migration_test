class AddTouchedToPeople < ActiveRecord::Migration
  def change
    add_column :people, :touched, :boolean, :default => false
  end
end
