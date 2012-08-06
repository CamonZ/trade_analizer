class CreateExecutionsDays < ActiveRecord::Migration
  def change
    create_table :executions_days do |t|
      t.timestamps
    end
  end
end
