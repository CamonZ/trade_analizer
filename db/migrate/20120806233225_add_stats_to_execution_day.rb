class AddStatsToExecutionDay < ActiveRecord::Migration
  def change
    change_table :executions_days do |t|
      t.float :profit_and_loss
      t.float :wins
      t.float :losses
      t.float :wins_average
      t.float :losses_average
      t.float :win_percentage
      t.float :losses_percentage
      t.string :best_stock
      t.string :worst_stock
    end
  end
end
