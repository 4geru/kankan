def textUpdate(event)
   if Exam.last.updated_at.yday != Time.now.yday
    m = MessageConfirm.new('時間割アップデート確認')
    m.pushButton('はい',   {"data": "type=update&status=true",  "text": "アップデートして！"})
    m.pushButton('いいえ', {"data": "type=update&status=false"})
    client.reply_message(event['replyToken'], m.reply("時間割アップデート確認\n本当にアップデートしますか？"))
  else
    client.reply_message(event['replyToken'], { type: 'text', text: 'アップデートできないです' })
  end
end