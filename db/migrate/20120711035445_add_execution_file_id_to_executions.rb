class AddExecutionFileIdToExecutions < ActiveRecord::Migration
  def change
    change_table :executions do |t|
      t.references :executions_file
    end
  end
end
