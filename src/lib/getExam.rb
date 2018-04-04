require './app'
def getExam(department, grade, t)
  # p 'run'
  # month = 5
  # day = 3
  # year = 2018
  # grade = 4
  # department = 'igaku'
  # t = Time.new(year, month, day)
  dept = (department == 'igaku' ? '医学科' : '看護学科')
  exams = []
  0..14.times { |i|
    dday = t + i.day
    date = "#{dday.year}/#{(dday.month == 12 ? "0" : dday.month)}/#{dday.day}"
    ret = Exam.where({department: department, grade: grade, date: date })
    exams << ret.to_a
  }
  if exams.flatten!.empty?
    msg = '直近2週間にテストはありません。'
  else
    msg = exams.map{|exam|
      table = eval(exam['timetable']).map{|time|
        "#{time["period"]}時限目 #{time["title"]}"
      }
      "#{exam["date"]}\n" +
      "#{table.join("\n")}"
    }.join("\n\n")
  end
  p msg
  msg
end