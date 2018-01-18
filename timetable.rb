##
# get from api
#  - department, grade, month, day
# return msg
def op(department, grade, month = 4, day = 1)
  t = Time.new('2017', month, day)
  month = month.to_i
  date = t.year.to_s + '/' + (month == 12 ? "0" : month.to_s) + '/' + day.to_s
  p [department, grade, date]
  lectures = Day.where({department: department, grade: grade, date:date}).first
  dept = (department == 'igaku' ? '医学科' : '看護学科')
  msg = "#{month}月#{day}日 (#{weekName(t.wday)}) #{dept} #{grade}年生"
  p lectures
  if not lectures['isHoliday']
    eval(lectures['timetable']).each_with_index do |lecture, i|
       next if lecture['title'] == ''
       msg += "\n#{lecture['period']}限目 #{lecture['title']} \u{1F6A9} #{lecture['room']}\n  \u{1F4D4}  #{lecture['subtitle']}\n  \u{1F468}  #{lecture['professor']}"
     end
  else
    msg = lectures['reason'] + 'です.'
  end
  msg
end

def getEndTime(department, grade, month = 4, day = 1)
  t = Time.new('2017', month, day)
  month = month.to_i
  date = t.year.to_s + '/' + (month == 12 ? "0" : month.to_s) + '/' + day.to_s
  lecture = Day.where({department: department, grade: grade, date: date}).first
  return lecture["reason"] if lecture["isHoliday"]
  last_lecture = eval(lecture["timetable"]).select{|lecture| lecture["title"] != ""}.max{|a,b| a["period"] <=> b["period"]}
  last_period = last_lecture["period"].to_i
  p last_lecture
  time = {1 => ["8:50", "10:20"], 2 => ["10:30", "12:00"], 3 => ["13:00", "14:30"], 4 => ["14:40", "16:10"], 5 => ["16:20", "17:50"]}
  "#{month}/#{day}(#{weekName(t.wday)})の終了時間だね！\n#{last_period}限の#{last_lecture["title"]}までで\n\u{23F0}#{time[last_period][1]}までだよ！"
end
