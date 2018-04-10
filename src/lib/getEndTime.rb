def getEndTime(department, grade, t)
  month = t.month
  day = t.day
  date = t.year.to_s + '/' + (month == 12 ? "0" : month.to_s) + '/' + day.to_s
  lectures = Day.find_by({department: department, grade: grade, date: date })
  timetable = eval(lectures['timetable'])

  dept = (department == 'igaku' ? '医学科' : '看護学科')
  msg = "#{t.month}月#{t.day}日 (#{weekName(t.wday)}) #{dept} #{grade}年生"
  return "#{msg}\n#{lectures['reason']}です" if lectures['isHoliday']
  last_lecture = timetable.last
  last_period  = last_lecture["period"].to_i

  time = {1 => ["8:50", "10:20"], 2 => ["10:30", "12:00"], 3 => ["13:00", "14:30"], 4 => ["14:40", "16:10"], 5 => ["16:20", "17:50"]}

  msg +
  "の終了時間だね！\n" +
  "#{last_period}限の#{last_lecture["title"]}までで\n" +
  "\u{23F0}#{time[last_period][1]}までだよ！"
end
