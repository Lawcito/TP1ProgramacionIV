class CreateCourts < ActiveRecord::Migration[8.1]
  def change
    create_table :courts do |t|
      t.string :name
      t.decimal :price
      t.boolean :covered

      t.timestamps
    end
    add_index :courts, :name, unique: true
  end
end
