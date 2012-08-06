class AddExecutionFileIdToExecutions < ActiveRecord::Migration
  def change
    change_table :executions do |t|
      t.references :executions_day
    end
  end
end
