class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :court, null: false, foreign_key: true
      t.references :time_slot, null: false, foreign_key: true
      t.date :date
      t.integer :status

      t.timestamps
    end
  end
end
