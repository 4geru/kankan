require 'nokogiri'
require 'open-uri'
require 'kconv'

def examTimetable(doc, month = 0, day = 11)
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
      # print "%d %s\n" % [period, inf]
      inf[0] = period
      inf.push('') if inf.length == 2
      inf.push('') if inf.length == 3
      ary = [key, inf].transpose
      lecture = Hash[*ary.flatten]
      lecture['room'] = room
      if lecture['subtitle'] =~ /テスト/ or lecture['subtitle'] =~ /試験/
        lectures.push(lecture)
      end
    end
  end
  lectures.each_with_index do |lecture, i| 
    if i != lectures.length - 1 and lectures[i]["title"] == lectures[i+1]["title"]
      lecture["period"] = lecture["period"].to_s + "-" + lectures[i+1]["period"].to_s
      lectures.delete(lecture[i+1])
    end
  end
  lectures
end

def examGetHP(td)
  if td.length == 3
    # 休みの日
    return nil
  else
    # 休みの日
    isholiday = true
    td[2..12].each do |t|
      isholiday = false if t.inner_text.gsub(/[\t\r\n]/, '') != ''
    end
    return nil if isholiday 
    timetable = examTimetable(td)
    return nil if timetable.length == 0

    return {isholiday: false, classes: timetable}
  end
end

def exam()
  # [['igaku', 6], ['kango', 4]].each do |i|
  [['igaku', 1]].each do |i|
    department = i[0]
    year = i[1]
    year.times do |y|
      url = 'http://www.shiga-med.ac.jp/~hqgaku/SchoolCalendar/' + department + '/' + (y+1).to_s + '/calendar_d.html'
      # url = 'http://www.shiga-med.ac.jp/~hqgaku/SchoolCalendar/' + department + '/' + (3).to_s + '/calendar_d.html'
      puts url
      html_txt = open(url).read
      html_txt_utf8 = html_txt.kconv(Kconv::UTF8, Kconv::EUC)
      doc = Nokogiri(html_txt_utf8,'nil','UTF-8')

      doc.xpath('//table[@class="table_layout"]').each_with_index do |table, i|
        table.xpath('tr').each_with_index do |tr, j|
          next if tr.xpath('td').length == 7
          lectures = examGetHP(tr.xpath('td'))
          # next if lectures[:classes].nil?
          next if lectures == nil
          date = "2017/%d/%d" % [(i + 4)%12, j]
          # p date
          obj = { 
            'grade' => y + 1, 
            'department' => department, 
            'date' => date,
            'timetable' => (lectures[:classes].to_s || ""),
          }
          Exam.create(obj)
          # f.puts("Exam.create(" + obj.to_s + ")")
        end
      end
      sleep 3
    end
  end

  'ok'
end