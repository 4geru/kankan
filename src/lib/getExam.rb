require './app'
def getExam(department, grade, t)
  dept = (department == 'igaku' ? '医学科' : '看護学科')
  exams = []
  # [TODO] 直す
  0..14.times { |i|
    dday = t + i.day
    date = "#{dday.year}/#{(dday.month == 12 ? "0" : dday.month)}/#{dday.day}"
    ret = Exam.where({department: department, grade: grade, date: date })
    exams << ret.to_a
  }
  msg = "#{t.month}月#{t.day}日 (#{weekName(t.wday)}) #{dept} #{grade}年生"
  return "#{msg}\n直近2週間にテストはありません" if exams.flatten!.empty?

  msg + exams.map{|exam|
    table = eval(exam['timetable']).map{|time|
      "#{time["period"]}時限目 #{time["title"]}"
    }.join("\n")
    "#{exam["date"]}\n" + "#{table}"
  }.join("\n\n")
end