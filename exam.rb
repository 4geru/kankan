##
# get from api
#  - department, grade, month, day
# return exam msg
def exam(department, grade, month = 4, day = 1)
  t = Time.new
  month = month.to_i
  date = t.year.to_s + '/' + (month == 12 ? "0" : month.to_s) + '/' + day.to_s
  p [department, grade, date]

  lectures = Exam.where({department: department, grade: grade, date:date}).first
  dept = (department == 'igaku' ? '医学部' : '看護学部')
  msg = "#{month}月#{day}日 #{dept} #{grade}年生"
  p "#{date}, #{grade}, #{department}"
  return nil unless lectures
  eval(lectures['timetable']).each_with_index do |lecture, i|
    next if lecture['title'] == ''
    msg += "\n#{lecture['period']}限目 #{lecture['title']} \u{1F6A9} #{lecture['room']}\n  \u{1F4D4}  #{lecture['subtitle']}\n  \u{1F468}  (#{lecture['professor']})\n" 
  end
  msg 
end

def exams(department, grade, month, day)
  t = Time.new('2017', month, day)

  exams = ""
  14.times do |i|
    exam = exam(department, grade, t.strftime("%m"), t.strftime("%d"))
    t = t + (60 * 60 * 24)
    next if not exam
    exams += exam
  end
  exams = "2週間以内にテストはありません" if exams.length == 0
  exams
end