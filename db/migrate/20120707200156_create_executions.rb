class CreateExecutions < ActiveRecord::Migration
  def change
    create_table :executions do |t|
      t.date :date
      t.datetime :time
      t.string :symbol
      t.integer :shares
      t.float :price
      t.string :side
      t.string :contra
      t.integer :liquidity
      t.float :profit_and_loss

      t.timestamps
    end
  end
end
