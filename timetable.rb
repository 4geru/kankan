##
# get from api
#  - department, grade, month, day
# return msg
def op(department, grade, month = 4, day = 1)
  t = Time.new

  date = t.year.to_s + '/' + (month.to_i == 12? "0" : month.to_s) + '/' + day.to_s
  lectures = Day.where({department: department, grade: grade, date:date}).first
  dept = (department == 'igaku' ? '医学部' : '看護学部')
  msg = "#{month}月#{day}日 #{dept} #{grade}年生"
  if not lectures['isHoliday']
    eval(lectures['timetable']).each_with_index do |lecture, i|
       next if lecture['title'] == ''
       msg += "\n#{lecture['period']}限目 #{lecture['title']} \u{1F6A9} #{lecture['room']}\n  \u{1F4D4}  #{lecture['subtitle']}\n  \u{1F468}  (#{lecture['professor']})" 
     end
  else
    msg = lectures['reason'] + 'です.'
  end
  msg 
end