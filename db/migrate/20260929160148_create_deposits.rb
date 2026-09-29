class CreateDeposits < ActiveRecord::Migration[8.1]
  def change
    create_table :deposits do |t|
      t.references :reservation, null: false, foreign_key: true
      t.decimal :amount

      t.timestamps
    end
  end
end
