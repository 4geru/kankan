require 'levenshtein'

# LINEのIDを取得できます
def get_id(event)
  case event["type"]
  when "user"
    return event["userId"]
  when "group"
    return event["groupId"]
  when "room"
    return event["roomId"]
  else
    return "error"
  end
end

# 編集距離を求めてくれます
def levenshteinWord(title, lectures)
  # title = "薬"
  # lectures = ["薬理学実習", "神経薬理学総論", "薬理学", "薬物医療学"]
  min = 1000
  min_lecture = {}
  lectures.each do |lecture|
    if min > Levenshtein.distance(title, lecture["title"])
      min_lecture = lecture
      min = Levenshtein.distance(title, lecture["title"])
    end
  end
  p min_lecture, min
  return min_lecture, min
end

def weekName(num)
  weeks = ['月', '火', '水', '木', '金', '土', '日']
  weeks[num]
end

def getDate(message)
  t = Time.new()
  if message =~ /今日/
    t = t
  elsif message =~ /明日/
    t = Time.new(t.year, t.month, t.day + 1)
  elsif message =~ /明後日/
    t = Time.new(t.year, t.month, t.day + 2)
  elsif message =~ /(\d{1,2})\/(\d{1,2})/
    begin
      m = message.match(/(\d{1,2})\/(\d{1,2})/)
      t = Time.parse("#{t.year}/#{m[1]}/#{m[2]}")
    rescue => e
      puts '日付の入力を直してください 月/日'
      t = nil
    end
  else
    t = nil
  end
  t
end
