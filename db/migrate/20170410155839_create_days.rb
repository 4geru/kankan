class CreateDays < ActiveRecord::Migration
  def change
    create_table :days do |t|
      t.string  :date, default: ""
      t.boolean :isHoliday, default: false
      t.string  :reason, default: ""
      t.string  :timetable, default: ""
      t.integer :grade
      t.string  :department
      t.integer :period
    end
  end
end
