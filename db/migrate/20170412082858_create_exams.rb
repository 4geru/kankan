class CreateExams < ActiveRecord::Migration
  def change
    create_table :exams do |t|
      t.integer  :grade
      t.string   :department
      t.string   :date
      t.string   :timetable
      t.timestamps null: false
    end
  end
end
