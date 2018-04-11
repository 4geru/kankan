def bus_start_at(start)
  msg = "今日のバスの情報\n"
  t = Time.now
  trips = search_bus(start, t)
  p trips.length
  if trips.empty?
    p 'run empty'
    t = t - t.seconds_since_midnight + 26 * 60 * 60
    msg = "明日のバスの情報\n※今日の営業は終了しています。\n"
    trips = search_bus(start, t)
  end
  return "今日・明日の運行がありません。" if trips.empty?

  msg + "出発(#{start}) >> 到着(#{trips.first.goal})\n" +
  trips[0...5].map{|trip|
    "\u{1F4CD} #{trip.start_time} \u{1F68C}  #{trip.goal_time}"
  }.join("\n")
end

def search_bus(start, t)
  Trip.where({start: start}).select{|trip|
    trip.startAt(t) > t and
    (
      (t.sunday? and trip.status == '日祝') or # 0
      (t.saturday? and trip.status == '土曜') or# 6
      (not (t.sunday? or t.saturday?) and trip.status == '平日')# other
    )
  }.sort!{|a, b| a.startAt <=> b.startAt }
end