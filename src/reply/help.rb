def help(token)
  m  = MessageCarousel.new('設定選択中')
  m1 = MessageButton.new('hoge')
  m2 = MessageButton.new('hoge')
  m1.pushButton('カンカンを広める', {"type": "uri", "uri": "line://nv/recommendOA/@zrc5093f", "text": "カンカンをシェアする"})
  m1.pushButton('要望・リクエスト', {"type": "uri", "uri": "https://goo.gl/forms/LX279L52DN1tNfHJ2", "text": "ここ変えて欲しい"})
  m2.pushButton('学年変更', {"data": "type=help&order=upgrade", "text": "学年を変更したい"})
  m2.pushButton('時間割の更新をする', {"data": "type=help&order=update", "text": "時間割をアップデートして"})
  reply = m.reply([
    m1.getButtons('カンカン設定', '要望を送ったり他の人にシェアできるよ！'),
    m2.getButtons('カンカン設定', '設定を帰るかな？！')
  ])
  client.reply_message(token, [
    { type: 'text', text: "まだまだ成長できるから、どんどん要望を送ってね！"},
    reply
  ])
end