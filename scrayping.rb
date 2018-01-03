require './scrayping/exam'
require './scrayping/day'

def reset
  Exam.all.map{|exam| exam.delete}
  Day.all.map{|day| day.delete}
  exam()
  day()
end