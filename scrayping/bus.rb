require 'mechanize'
require 'open-uri'

class Stop
  def initialize(url, goal)
    sleep 3
    agent = Mechanize.new
    @url = url
    @goal = goal
    @page = agent.get(url)
    puts @page.css('h3').inner_text.split('　')[0..1]
    puts @page.css('h3').inner_text.split('　')[2]
  end

  def search
    bins = @page.css('table a')[2..-1]
    url_base = @url.split('/')[0..-2].join('/')
    bins[0..0].map{ |bin|
      next_url = url_base + '/' + bin.get_attribute(:href)
      route = Bin.new(next_url, @goal).search
    }
  end
end

class Bin
  def initialize(url, stop)
    sleep 3
    agent = Mechanize.new
    @page = agent.get(url)
    @stop = stop
  end

  def search
    reg = Regexp.new(@stop)
    start = @page.css('font')[0].inner_text
    goal = nil
    @page.css('table')[2].css('td').each{|td|
      if reg.match(td.inner_text)
        goal = td.inner_text.gsub(/[^\d:]/, "")
      end
    }
    [start, goal]
  end
end

urls = [
  'http://www.teisan-qr.com/jikoku/stop/iku/222_4_1.php',
  'http://www.teisan-qr.com/jikoku/stop/iku/222_5_1.php',
  'http://www.teisan-qr.com/jikoku/stop/iku/222_6_2.php',
  'http://www.teisan-qr.com/jikoku/stop/iku/222_7_3.php'
]

urls[0..0].map{ |url|
  page = Stop.new(url, '医大西門')
  bins = page.search
  puts bins
}