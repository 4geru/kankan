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

def getHP(td)
  if td.length == 3
    # 休みの日
    title = ''
    if td[2].inner_text.gsub(/[\t\n\r]/,'') == ''
      title = "\u{1F4A4} お休み"
    else
      title = "\u{3297}" + td[2].inner_text.gsub(/[\t\n\r]/,'').gsub('　','')
    end
    return {isholiday: true, title: title}
  else
    # 休みの日
    isholiday = true
    td[2..12].each do |t|
      isholiday = false if t.inner_text.gsub(/[\t\r\n]/, '') != ''
    end
    return {isholiday: true, title: '\u{1F4A4} お休み'} if isholiday 
    return {isholiday: false, classes: timetable(td)}
  end
end

def op(month = 4, day = 1)
  month = (month.to_i + 8) % 12
  day = day.to_i
  url = 'http://www.shiga-med.ac.jp/~hqgaku/SchoolCalendar/igaku/3/calendar_d.html'
  html_txt = open(url).read
  html_txt_utf8 = html_txt.kconv(Kconv::UTF8, Kconv::EUC)
  doc = Nokogiri(html_txt_utf8,'nil','UTF-8')

  td = doc.xpath('//table[@class="table_layout"]')[month].xpath('tr')[day].xpath('td')

  lectures = getHP(td)
  msg = ''
  if not lectures[:isholiday]
    lectures[:classes].each_with_index do |lecture, i|
      next if lecture['title'] == ''
      msg += "#{i+1}限目 #{lecture['title']} \u{1F6A9} #{lecture['room']}\n  \u{1F4D4}  #{lecture['subtitle']}\n  \u{1F468}  (#{lecture['professor']})\n" 
    end
  else
    msg = lectures[:title] + 'です.'
  end
  msg 
end

def exam(month = 4, day = 1)
  url = 'http://www.shiga-med.ac.jp/~hqgaku/SchoolCalendar/igaku/3/calendar_d.html'

  html_txt = open(url).read
  html_txt_utf8 = html_txt.kconv(Kconv::UTF8, Kconv::EUC)
  doc = Nokogiri(html_txt_utf8,'nil','UTF-8')

  t = Time.new(2017,month,day)
  exam = []
  for i in (0..7).to_a
    d = t + (i*60*60*24)
    month = (d.month.to_i + 8) % 12
    td = doc.xpath('//table[@class="table_layout"]')[month].xpath('tr')[d.day].xpath('td')
    lectures = getHP(td)
    next if lectures[:isholiday]
    lectures[:classes].each_with_index do |lecture, i|
      if lecture['subtitle'] =~ /試験/ or lecture['subtitle'] =~ /テスト/
        exam.push({
          month: d.month,
          day: d.day,
          term: i + 1,
          title: lecture['title'],
          subtitle: lecture['subtitle']
        })
      end
    end
  end
  msg = ''
  exam.each_with_index do |lecture, i|
    term = exam[i][:term].to_s
    if exam.length - 1 != i and exam[i][:title] == exam[i+1][:title] and exam[i][:subtitle] == exam[i+1][:subtitle]
      term += "-#{exam[i+1][:term]}"
      exam.delete(exam[i+1])
    end
    msg += "#{lecture[:month]}/#{lecture[:day]} #{term}限目 #{lecture[:title]}\n  \u{1F4D4}  #{lecture['subtitle']}\n"
  end
  msg
end