class Action
  def initialize(event)
    @event = event
    @token = event['replyToken']
    @user_id = event["source"]["userId"]
    @room = Room.find_or_create_by(channel_id: @user_id)
    @type = ""#"exam"
    @jp_type1 = ""#"テスト"
    @jp_type2 = ""#"テスト期間"
  end

  def get_array(t)
    dept  = @room["department"]
    grade = @room["grade"]
    date = "#{t.year}/#{(t.month == 12 ? "0" : t.month)}/#{t.day}"

    Day.find_by({department: dept, grade: grade, date: date })
  end

  def postback(data)
    t =  Time.new() #  data["order"] == 'today'
    if data["order"] == "calendar"
      y, m, d = @event["postback"]["params"]["date"].split('-')
      t = Time.new(y, m, d)
    end
    msg = get_detail(t)
    client.reply_message(@token,{ type: 'text', text: msg })
  end

  def text
    m  = MessageCarousel.new("#{@jp_type2}を選択中")
    m1 = MessageButton.new('hoge')
    m1.pushButton("\u{1F4CD} 今日の#{@jp_type1}", {"data": "type=#{@type}&order=today"})
    m1.pushButton("\u{1F4C5} 日付を選択", {
      "type": "datetimepicker",
      "data": "type=#{@type}&order=calendar",
      "text": "調べたい日を伝える！",
      "mode": "date"
    })
    reply = m.reply([ m1.getButtons("#{@jp_type1}検索", '探したい日付を教えてね！') ])
    client.reply_message(@token, [ sticky, reply ])
  end

  def get_header(t)
    dept  = (@room["department"] == 'igaku' ? '医学科' : '看護学科')
    grade = @room["grade"]
    "#{t.month}月#{t.day}日 (#{weekName(t.wday)}) #{dept} #{grade}年生"
  end

  def get_detail(data)
    client.reply_message(@token,{ type: 'text', text: get_message(data) })
  end

  def get_message(data)
    t =  Time.new() #  data["order"] == 'today'
    if data["order"] == "calendar"
      y, m, d = @event["postback"]["params"]["date"].split('-')
      t = Time.new(y, m, d)
    end
    get_init_message(t, get_array(t))
  end
end