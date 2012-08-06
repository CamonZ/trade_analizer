class AddDateToExecutionsDay < ActiveRecord::Migration
  def change
    change_table :executions_days do |t|
      t.date :date
    end
  end
end
