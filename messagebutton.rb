class MessageButton
  def initialize(altText = nil)
    @buttons = [] 
    @altText = altText
  end

  def reply(title = nil, text = nil, altText = nil)
  return nil if @buttons.length == 0
  return nil if title.nil?
  return nil if text.nil?
  @altText = altText if altText
  {
    "type": "template",
    "altText": @altText || "this is a buttons template",
    "template": {
        "type": "buttons",
        "title": title,
        "text": text,
        "actions": @buttons
    }
  }
  end

  # option : {data=nil, url=nil}
  def pushButton(label='', option)
    @buttons.push(option.merge({"type": "postback", "label": label}))
  end

end