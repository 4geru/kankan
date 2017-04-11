class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string  :channel_id
      t.string  :department
      t.integer :grade
      t.timestamps null: false
    end
  end
end
