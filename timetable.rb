require 'nokogiri'
require 'open-uri'
require 'logger'  
require 'kconv'

def timetable(doc, month = 0, day = 11)
  tr = doc[2..12]
  lectures = []
  0.step(8, 2) do |i|
    info = tr[i].inner_text.gsub(/\t/,'').split(/\r\n/)
    room = tr[i+1].inner_text.gsub(/\\t/,'')
    info = ['', '', '', ''] if info.length == 0
    key = ['buf', 'title', 'professor', 'subtitle']
    ary = [key, info].transpose
    lecture = Hash[*ary.flatten]
    lecture['room'] = room
    lectures.push(lecture)
  end
  lectures
end

def getHP(month = 4, day = 1)
  month = (month.to_i + 8) % 12
  day = day.to_i
  url = 'http://www.shiga-med.ac.jp/~hqgaku/SchoolCalendar/igaku/3/calendar_d.html'

  html_txt = open(url).read
  html_txt_utf8 = html_txt.kconv(Kconv::UTF8, Kconv::EUC)
  doc = Nokogiri(html_txt_utf8,'nil','UTF-8')

  td = doc.xpath('//table[@class="table_layout"]')[month].xpath('tr')[day].xpath('td')

  if td.length == 3
    # 休みの日
    if td[2].inner_text.gsub(/[\t\n\r]/,'') == ''
      title = '授業なし'
    else
      title = td[2].inner_text.gsub(/[\t\n\r]/,'').gsub('　','')
    end
    return {isholiday: true, title: title}
  else
    # 休みの日
    isholiday = true
    td[2..12].each do |t|
      isholiday = false if t.inner_text.gsub(/[\t\r\n]/, '') != ''
    end
    return {isholiday: true, title: '授業なし'} if isholiday 
    return {isholiday: false, classes: timetable(td)}
  end
end

def op(month = 4, day = 1)
  lectures = getHP(month, day)
  msg = ""
  msg = ''
  if not lectures[:isholiday]
    lectures[:classes].each_with_index do |lecture, i|
      next if lecture['title'] == ''
      msg += "#{i+1}限目 #{lecture['title']} 教室 #{lecture['room']}\n - #{lecture['subtitle']} - \n(#{lecture['professor']})\n" 
    end
  else
    msg = 'お休みです.'
  end
  msg 
end