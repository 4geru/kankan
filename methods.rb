def commands
  content = [
    "\u{1F4AC}[今日,曜日,日付(月/日)]の授業は？",
    "　\u{2705} 時間割を教えるよ！",
    "\u{1F4AC}[科目(略称可)]のテストは？",
    "　\u{2705} 試験を教えるよ！",
    "\u{1F4AC}[日付(月/日)]のテストは？",
    "　\u{2705} 2週間以内の試験を教えるよ！",
    "\u{1F4AC}[今日,曜日,日付(月/日)]何時まで？",
    "　\u{2705} 終わりの時間を教えてくれるよ！",
    "\u{1F4AC}カンカン設定！",
    "　\u{2705} 学科,学年を変更できるよ！",
    "\u{1F4AC}カンカンヘルプ！",
    "　\u{2705} 指示の一覧が見れるよ！"]
  content.join("\n")
end

def help(token)
  m  = MessageCarousel.new('学年選択中')
  m1 = MessageButton.new('hoge')
  m2 = MessageButton.new('hoge')
  m1.pushButton('コマンド教えて', {"data": "type=help&order=command", "text": "コマンドを教えて"})
  m1.pushButton('授業日から選択する',
  { "type": "datetimepicker", "data": "type=help&order=calendar", "text": "日付を教える！",
    "mode": "date"
  })
  m1.pushButton('カンカンを広める', {"type": "uri", "uri": "line://ti/p/@zrc5093f", "text": "カンカンをシェアする"})
  m2.pushButton('学年変更', {"data": "type=help&order=upgrade", "text": "学年を変更したい"})
  m2.pushButton('時間割の更新をする', {"data": "type=help&order=update", "text": "時間割をアップデートして"})
  m2.pushButton('要望・リクエスト', {"type": "uri", "uri": "https://goo.gl/forms/LX279L52DN1tNfHJ2", "text": "ここ変えて欲しい"})
  reply = m.reply([
    m1.getButtons('カンカン設定', '設定を調べてね！'),
    m2.getButtons('カンカン設定', '変更・要望を教えてね！')
  ])
  p reply
  client.reply_message(token, [
    { type: 'text', text: "まだまだ成長できるから、どんどん要望を送ってね！"},
    reply
  ])
end