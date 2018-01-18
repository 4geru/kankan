require './scrayping/day'

def reset(department, year)
  Exam.where(department: department, grade: year).map{|exam| exam.delete}
  Day.where(department: department, grade: year).map{|day| day.delete}
  getDay(department, year)
end