def startAction
    m = MessageButton.new('学科選択中')
    m.pushButton('医学科',   {"data": "type=dept&department=igaku"})
    m.pushButton('看護学科', {"data": "type=dept&department=kango"})
    m.reply('学科選択', '初めまして！カンカンです！学科を教えてね！')
end