def text_bus(event)
  m = MessageConfirm.new('バス出発地点洗濯中')
  m.pushButton('瀬田駅',   {"data": "type=bus&pin=seta"})
  m.pushButton('医大西門', {"data": "type=bus&pin=idai"})
  client.reply_message(event['replyToken'], [ sticky, m.reply("バス時刻表\nどこから出発しますか？")])
end