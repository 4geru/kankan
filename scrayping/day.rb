require 'nokogiri'
require 'open-uri'
require 'kconv'

def getTd(doc)
  tr = doc[2..12]
  lectures = []
  exam = []
  0.step(8, 2) do |i|
    info   = tr[i].inner_text.gsub(/\t/,'').split(/\r\n/)
    room   = tr[i+1].inner_text.gsub(/\\t/,'')
    period = i / 2 + 1
    info = ['', '', '', ''] if info.length == 0
    key = ['period', 'title', 'professor', 'subtitle']
    info.each_slice(4).to_a.each do | inf |
      lecture = {}
      inf[0] = period
      inf.push('') if inf.length == 2
      inf.push('') if inf.length == 3
      ary = [key, inf].transpose
      lecture = Hash[*ary.flatten]
      lecture['room'] = room
      lectures.push(lecture)
      if lecture['subtitle'] =~ /テスト/ or lecture['subtitle'] =~ /試験/
        exam.push(lecture)
      end

    end
  end
  {lectures: lectures, exam: exam}
end

def getTr(td)
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
    return {isholiday: false, classes: getTd(td)}
  end
end

def getDay(department, grade)
  puts grade
  puts department
  url = "http://www.shiga-med.ac.jp/~hqgaku/SchoolCalendar/#{department}/#{grade}/calendar_d.html"
  print url
  html_txt = open(url).read
  html_txt_utf8 = html_txt.kconv(Kconv::UTF8, Kconv::EUC)
  doc = Nokogiri(html_txt_utf8,'nil','UTF-8')
  t = Time.now
  doc.xpath('//table[@class="table_layout"]').each_with_index do |table, i|
    table.xpath('tr').each_with_index do |tr, j|
      next if tr.xpath('td').length == 7
      lectures, exam = getTr(tr.xpath('td'))

      date = "%d/%d/%d" % [t.year,(i + 4)%12, j]
      puts "class => #{lectures[:classes]}"
      obj = {
        'grade' => grade,
        'department' => department,
        'date' => date,
        'isHoliday' => lectures[:isholiday].to_s,
        'timetable' => (lectures[:classes].nil? ? "" :lectures[:classes][:lectures].to_s),
        'reason' => (lectures[:title] || ""),
      }
      Day.create(obj)
      next if lectures[:classes].nil? or lectures[:classes][:exam].length == 0
      obj = {
        'grade' => grade,
        'department' => department,
        'date' => date,
        'timetable' => (lectures[:classes][:exam].to_s || "")
      }
      Exam.create(obj)
    end
  end
  sleep 3
end
