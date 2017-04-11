##
# get from api
#  - department, grade, month, day
# return msg
def op(department, grade, month = 4, day = 1)
  t = Time.new
  date = t.year.to_s + '/' + month.to_s + '/' + day.to_s
  lectures = Day.where({department: department, grade: grade, date:date})[0]
  msg = ''
  if not lectures.isHoliday
    eval(lectures.timetable).each_with_index do |lecture, i|
       next if lecture['title'] == ''
       msg += "#{lecture['period']}限目 #{lecture['title']} \u{1F6A9} #{lecture['room']}\n  \u{1F4D4}  #{lecture['subtitle']}\n  \u{1F468}  (#{lecture['professor']})\n" 
     end
  else
    msg = lectures.reason + 'です.'
  end
  msg 
end