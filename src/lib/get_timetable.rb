##
# get from api
#  - department, grade, month, day
# return msg
def get_timetable(department, grade, t)
  date = "#{t.year}/#{(t.month == 12 ? "0" : t.month)}/#{t.day}"
  lectures = Day.find_by({department: department, grade: grade, date: date })
  dept = (department == 'igaku' ? '医学科' : '看護学科')
  msg = "#{t.month}月#{t.day}日 (#{weekName(t.wday)}) #{dept} #{grade}年生\n"
  p lectures
  return "#{msg}#{lectures['reason']}です" if lectures['isHoliday']
  eval(lectures['timetable']).each_with_index do |lecture, i|
     next if lecture['title'] == ''
     msg += "#{lecture['period']}限目 #{lecture['title']} \u{1F6A9} #{lecture['room']}\n  \u{1F4D4}  #{lecture['subtitle']}\n  \u{1F468}  #{lecture['professor']}"
  end
  return msg
end

