require './src/class/Action'

class ActionExam < Action
  def initialize(event)
    super
    @type = "exam"
    @jp_type1 = "テスト"
    @jp_type2 = "テスト期間"
  end

  def get_grade_header
    dept  = (@room["department"] == 'igaku' ? '医学科' : '看護学科')
    grade = @room["grade"]
    "#{dept} #{grade}年生\n"
  end

  def get_sub_header(m)
    m = m.split('/')
    t = Time.now
    t = Time.parse("#{t.year}/#{m[1]}/#{m[2]}")
    "#{t.month}月#{t.day}日 (#{weekName(t.wday)})\n"
  end

  def get_array(t)
    ([1] * 14)
    .inject([0]){|b, i| b << (b[-1] + 1)} # 0-14の配列を作る
    .map{ |i|
      dday = t + i.day
      date = "#{dday.year}/#{(dday.month == 12 ? "0" : dday.month)}/#{dday.day}"
      ret = Exam.where({department: @room["department"], grade: @room["grade"], date: date })
    }
  end

  def get_init_message(t, array)
    return "#{get_grade_header}直近2週間にテストはありません" if array.flatten!.empty?
    get_grade_header + array.map{|exam|
      table = eval(exam['timetable']).map{|time|
        "#{time['period']}限目 #{time['title']} \u{1F6A9} #{time['room']}\n  \u{1F4D4}  #{time['subtitle']}\n  \u{1F468}  #{time['professor']}"
      }.join("\n")
      "#{get_sub_header(exam["date"])}" + "#{table}"
    }.join("\n\n")
  end
end