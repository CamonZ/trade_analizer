class CreateExecutionsFiles < ActiveRecord::Migration
  def change
    create_table :executions_files do |t|
      t.timestamps
    end
  end
end
