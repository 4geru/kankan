require 'mechanize'
require 'open-uri'

class Stop
  def initialize(url, goal)
    sleep 3
    agent = Mechanize.new
    @url = url
    @goal = goal
    @page = agent.get(url)
    @start = @page.css('h3').inner_text.split('　')[0]
    @trip = @page.css('h3').inner_text.split('　')[1]
    @status = @page.css('h3').inner_text.split('　')[2]
  end

  def search
    bins = @page.css('table a')[2..-1]
    url_base = @url.split('/')[0..-2].join('/')
    bins.map{ |bin|
      next_url = url_base + '/' + bin.get_attribute(:href)
      route = Bin.new(next_url, {goal: @goal,start: @start}, @status, @trip).search
    }
  end
end

class Bin
  def initialize(url, pos, status, trip)
    sleep 3
    agent = Mechanize.new
    @page = agent.get(url)
    @goal_dist = pos[:goal]
    @start_dist = pos[:start]
    @trip = trip
    @status = status
  end

  def search
    reg = Regexp.new(@goal_dist)
    start = @page.css('font')[0].inner_text
    goal = nil
    @page.css('table')[2].css('td').each{|td|
      if reg.match(td.inner_text)
        goal = td.inner_text.gsub(/[^\d:]/, "")
      end
    }
    puts "#{{start_time: start, goal_time: goal, goal: @goal_dist, start: @start_dist, status: @status, trip: @trip}}"
    {start_time: start, goal_time: goal, goal: @goal_dist, start: @start_dist, status: @status, trip: @trip}
  end
end

def setaToIdai
  urls = [
    'http://www.teisan-qr.com/jikoku/stop/iku/222_4_1.php',
    'http://www.teisan-qr.com/jikoku/stop/iku/222_7_1.php',
    'http://www.teisan-qr.com/jikoku/stop/iku/222_8_2.php',
    'http://www.teisan-qr.com/jikoku/stop/iku/222_9_3.php'
  ]

  urls.map{ |url|
    page = Stop.new(url, '医大西門')
    bins = page.search
  }
end

def idaiToSeta
  urls = [
    'http://www.teisan-qr.com/jikoku/stop/iku/205_1_1.php',
    'http://www.teisan-qr.com/jikoku/stop/iku/205_2_1.php',
    'http://www.teisan-qr.com/jikoku/stop/iku/205_3_2.php',
    'http://www.teisan-qr.com/jikoku/stop/iku/205_4_3.php'
  ]

  urls.map{ |url|
    page = Stop.new(url, '瀬田駅')
    bins = page.search
  }
end

setaToIdai
idaiToSeta