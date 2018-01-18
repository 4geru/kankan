class MessageConfirm
  def initialize(altText = nil)
    @buttons = []
    @altText = altText
  end

  def reply(text = nil)
  return nil if @buttons.length == 0
  return nil if text.nil?
  {
    "type": "template",
    "altText": @altText || "this is a buttons template",
    "template": {
        "type": "confirm",
        "text": text,
        "actions": @buttons
    }
  }
  end

  def getButtons(title = nil, text = nil)
    return nil if @buttons.length == 0
    return nil if title.nil?
    return nil if text.nil?
    {
      "title": title,
      "text": text,
      "actions": @buttons
    }
  end
  # option : {data=nil, url=nil}
  def pushButton(label='', option)
    @buttons.push(option.merge({"type": "postback", "label": label}))
  end

end