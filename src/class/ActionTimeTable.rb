require './src/class/Action'

class ActionTimeTable < Action
  def initialize(event)
    super
    @type = "timetable"
    @jp_type1 = "授業"
    @jp_type2 = "授業日"
  end

  def get_detail(data)
    client.reply_message(@token,{ type: 'text', text: get_message(data) })
  end

  def get_array(t)
    dept  = @room["department"]
    grade = @room["grade"]
    date = "#{t.year}/#{(t.month == 12 ? "0" : t.month)}/#{t.day}"

    Day.find_by({department: dept, grade: grade, date: date })
  end

  def get_message(data)
    t =  Time.new() #  data["order"] == 'today'
    if data["order"] == "calendar"
      y, m, d = @event["postback"]["params"]["date"].split('-')
      t = Time.new(y, m, d)
    end
    get_message_timetable(t, get_array(t))
  end

  def get_message_timetable(t, array)
    return "#{get_header(t)}#{array['reason']}です" if array['isHoliday']
    get_header(t) + eval(array['timetable']).inject("") { |b, lecture|
      b +
      (
        lecture['title'] != '' ?
        "\n#{lecture['period']}限目 #{lecture['title']} \u{1F6A9} #{lecture['room']}\n  \u{1F4D4}  #{lecture['subtitle']}\n  \u{1F468}  #{lecture['professor']}" :
        ""
      )
    }
  end
end