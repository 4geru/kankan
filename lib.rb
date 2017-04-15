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
  weeks = ['日', '月', '火', '水', '木', '金', '土']
  weeks[num]
end 