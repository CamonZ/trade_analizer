class AddDefaultToPnl < ActiveRecord::Migration
  def up
    change_column(:executions, :profit_and_loss, :float, {:default => 0.0})
  end
  
  def down
    change_column(:executions, :profit_and_loss, :float, {:default => nil})
  end
end
