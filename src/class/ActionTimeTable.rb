require './src/class/Action'

class ActionTimeTable < Action
  def initialize(event)
    super
    @type = "timetable"
    @jp_type1 = "授業"
    @jp_type2 = "授業日"
  end

  def get_init_message(t, array)
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