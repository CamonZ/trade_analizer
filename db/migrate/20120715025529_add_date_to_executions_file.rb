class AddDateToExecutionsFile < ActiveRecord::Migration
  def change
    change_table :executions_files do |t|
      t.date :date
    end
  end
end
