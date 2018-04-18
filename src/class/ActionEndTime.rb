require './src/class/Action'

class ActionEndTime < Action
  def initialize(event)
    super
    @type = "endTime"
    @jp_type1 = "終了時間"
    @jp_type2 = "終了時間"
  end

  def get_detail(data)
    client.reply_message(@token,{ type: 'text', text: get_message(data) })
  end

  def get_array(t)
    dept  = @room["department"]
    grade = @room["grade"]
    date = "#{t.year}/#{(t.month == 12 ? "0" : t.month)}/#{t.day}"

    lectures = Day.find_by({department: dept, grade: grade, date: date })
  end

  def get_message(data)
    t =  Time.new() #  data["order"] == 'today'
    if data["order"] == "calendar"
      y, m, d = @event["postback"]["params"]["date"].split('-')
      t = Time.new(y, m, d)
    end
    get_message_endtime(t, get_array(t))
  end

  def get_message_endtime(t, array)
    return "#{get_header(t)}\n#{array['reason']}です" if array['isHoliday']
    lectures = eval(array['timetable'])
    last_period = lectures.select{|l| l["title"] != "" }.max{|a,b| a["period"] <=> b["period"] }
    time = {1 => ["8:50", "10:20"], 2 => ["10:30", "12:00"], 3 => ["13:00", "14:30"], 4 => ["14:40", "16:10"], 5 => ["16:20", "17:50"]}
    get_header(t) +
    "の終了時間だね！\n" +
    "#{last_period["period"]}限の#{last_period["title"]}まで" +
    "\u{23F0}#{time[last_period["period"]][1]}までだよ！"
  end
end