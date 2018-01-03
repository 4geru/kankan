require './scrayping/exam'
require './scrayping/day'


def reset
  Exam.all.map{|exam| exam.delete}
  Day.all.map{|day| day.delete}
  exam()
  day()
  system('bundle exec rake db:seed')
end