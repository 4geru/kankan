class MessageCarousel
  def initialize(altText = nil)
    @altText = altText
  end

  def reply(buttons)
  {
    "type": "template",
    "altText": @altText,
    "template": {
      "type": "carousel",
      "columns": buttons
    }
  }
  end
end