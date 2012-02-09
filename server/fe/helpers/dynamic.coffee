module.exports =
  
  # Render the flash messages.
  # 
  # req - passed by express
  # res - passed by express
  # 
  # Return an html string of the flash messages.
  messages: (req, res) ->
    messages = req.flash()
    return "" unless Object.keys(messages).length
    
    html = ""
    for type, message of messages
      html += "<div class='flash #{ type }'>#{ message }</div>"
      
    return html
