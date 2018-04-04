require './scrayping/day'

def reset(department, grade)
  Exam.where(department: department, grade: grade).map{|exam| exam.delete}
  Day.where(department: department, grade: grade).map{|day| day.delete}
  getDay(department, grade)
end
