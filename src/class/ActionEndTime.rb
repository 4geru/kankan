require './src/class/Action'

class ActionEndTime < Action
  def initialize(event)
    super
    @type = "endTime"
    @jp_type1 = "終了時間"
    @jp_type2 = "終了時間"
  end

  def get_init_message(t, array)
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