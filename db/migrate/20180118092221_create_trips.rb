class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.string   :start_time
      t.string   :goal_time
      t.string   :goal
      t.string   :start
      t.string   :trip
      t.string   :status
      t.timestamps null: false
    end
  end
end
