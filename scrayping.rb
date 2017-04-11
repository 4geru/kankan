require 'nokogiri'
require 'open-uri'
require 'kconv'

def timetable(doc, month = 0, day = 11)
  tr = doc[2..12]
  lectures = []
  0.step(8, 2) do |i|
    info   = tr[i].inner_text.gsub(/\t/,'').split(/\r\n/)
    room   = tr[i+1].inner_text.gsub(/\\t/,'')
    period = i / 2 + 1
    info = ['', '', '', ''] if info.length == 0
    key = ['period', 'title', 'professor', 'subtitle']
    info.each_slice(4).to_a.each do | inf |
      lecture = {}
      print "%d %s\n" % [period, inf]
      inf[0] = period
      inf.push('') if inf.length == 2
      inf.push('') if inf.length == 3
      ary = [key, inf].transpose
      lecture = Hash[*ary.flatten]
      lecture['room'] = room
      lectures.push(lecture)
    end
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
    return {isholiday: true, title: "\u{1F4A4} お休み"} if isholiday 
    return {isholiday: false, classes: timetable(td)}
  end
end

def op()

  File.open("seeds.rb", "w") do |f| 
  [['igaku', 6], ['kango', 4]].each do |i|
    department = i[0]
    year = i[1]
    year.times do |y|
      url = 'http://www.shiga-med.ac.jp/~hqgaku/SchoolCalendar/' + department + '/' + (y + 1).to_s + '/calendar_d.html'
      print url
      html_txt = open(url).read
      html_txt_utf8 = html_txt.kconv(Kconv::UTF8, Kconv::EUC)
      doc = Nokogiri(html_txt_utf8,'nil','UTF-8')

      doc.xpath('//table[@class="table_layout"]').each_with_index do |table, i|
        table.xpath('tr').each_with_index do |tr, j|
          next if tr.xpath('td').length == 7
          lectures = getHP(tr.xpath('td'))
          
          #d = Day.where({date: "2017/%d/%d" % [(i + 4)%12, j]})[0]
          date = "2017/%d/%d" % [(i + 4)%12, j]
          obj = { 
            'grade' => y + 1, 
            'department' => department, 
            'date' => date,
            'isHoliday' => lectures[:isholiday].to_s,
            'timetable' => (lectures[:classes].to_s || ""),
            'reason' => (lectures[:title] || ""),
          }

          f.puts("Day.create(" + obj.to_s + ")")
        end
      end
      sleep 3
    end
  end

  end
  'ok'
end

p op()