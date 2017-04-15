##
# get from api
#  - department, grade, month, day
# return exam msg
# 
def getExamMessage(lecture)
  "#{lecture['period']}限目 #{lecture['title']} \u{1F6A9} #{lecture['room']}\n  \u{1F4D4}  #{lecture['subtitle']}\n  \u{1F468}  (#{lecture['professor']})\n" 
end

def getExam(department, grade, month = 4, day = 1)
  t = Time.new
  month = month.to_i
  date = t.year.to_s + '/' + (month == 12 ? "0" : month.to_s) + '/' + day.to_s
  # p [department, grade, date]

  lectures = Exam.where({department: department, grade: grade, date:date}).first
  dept = (department == 'igaku' ? '医学部' : '看護学部')
  msg = "#{month}月#{day}日 #{dept} #{grade}年生\n"
  # p "#{date}, #{grade}, #{department}"
  return nil unless lectures
  eval(lectures['timetable']).each_with_index do |lecture, i|
    next if lecture['title'] == ''
    msg += getExamMessage(lecture)
  end
  msg 
end

def getExams(department, grade, month, day)
  t = Time.new('2017', month, day)

  exams = ""
  14.times do |i|
    exam = getExam(department, grade, t.strftime("%m"), t.strftime("%d"))
    t = t + (60 * 60 * 24)
    next if not exam
    exams += exam
  end
  exams = "2週間以内にテストはありません" if exams.length == 0
  exams
end

def getExamsTitle(department, grade, title)
  exams = Exam.where('(timetable like ?) and (grade = ?) and (department = ?)', "%#{title}%" , grade, department).uniq
  dept = (department == 'igaku' ? '医学部' : '看護学部')
  msg = ""
  min_exams = []
  exams.each do |exam|
    next if exam["date"].nil?
    lectures = eval(exam['timetable'])
    min_title, minv = levenshteinWord(title, lectures.map{|lecture| lecture})
    min_exams.push([min_title, minv, exam["date"]])
  end
  # 編集距離が最小の値を出す
  min_exams = min_exams.group_by{ |x| x[1] }.min{|a,b| a[0] <=> b[0]}

  # [0, [[{"period"=>"1-2", "title"=>"薬理学", "professor"=>"西", "subtitle"=>"中間テスト", "room"=>"臨３"}, 0, "2017/6/2"], [{"period"=>"1-2", "title"=>"薬理学", "professor"=>"西", "subtitle"=>"期末テスト", "room"=>"臨３"}, 0, "2017/7/25"]]]
  min_exams[1].each do |exam|
    m = exam[2].match(/(\d{1,4})\/(\d{1,2})\/(\d{1,2})/)
    msg += "#{m[2]}月#{m[3]}日 #{dept} #{grade}年生\n"
    msg += getExamMessage(exam[0])
  end
  print msg
  msg
end