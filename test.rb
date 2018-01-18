require 'bundler/setup'
Bundler.require
require './models/count'

def leave(start)
  t = Time.parse('2018/1/6 00:00')
  puts t.sunday?
  Trip.where({start: start}).select{|trip|
    trip.startAt > t and 
    (
      (t.sunday? and trip.status == '日祝') or # 0
      (t.saturday? and trip.status == '土曜') or# 6
      (not (t.sunday? or t.saturday?) and trip.status == '平日')# other
    )
  }.sort!{|a, b| a.startAt <=> b.startAt }
end

# start = '医大西門'
start = '瀬田駅'
trips = leave(start)
puts "trips >> #{trips}"
puts 'バスがないです' if trips.empty?


puts "出発(#{start}) >> 到着(#{trips.first.goal})"
trips[0...5].map{|trip|
  puts "\u{1F4CD} #{trip.start_time} \u{1F68C}  #{trip.goal_time}"
}