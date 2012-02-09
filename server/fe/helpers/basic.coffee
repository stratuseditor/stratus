color = require 'stratus-color'

# Generate the html attributes
# 
# Examples:
# 
#   hashToAttributes foo: "bar", dinner: "rice"
#   # => " foo='bar' dinner='rice'"
# 
# Return the html string.
hashToAttributes = (hash) ->
  html = ""
  for k, v of hash
    html += " #{k}='#{v}'"
  return html

module.exports =
  hashToAttributes: hashToAttributes
  
  # Generate html for an image tag.
  # 
  # src - The source of the image, relative to the "/images".
  # 
  # Examples
  # 
  #   imageTag "foo.png"
  #   # => "<img src='/images/foo.png'/>"
  # 
  #   imageTag "foo.png", alt: "Foo"
  #   # => "<img src='/images/foo.png' alt='Foo'/>"
  # 
  # Return the html string.
  imageTag: (src, attrs = null) ->
    extra = if attrs then hashToAttributes(attrs) else ""
    "<img src='/images/#{ src }'#{ extra }/>"
  
  # Generate html for a list of errors.
  # 
  # errors - A list of string errors.
  # 
  # Examples
  # 
  #   errorMessages ["My foot hurts", "You need a hard hat"]
  #   # => "<ul class='errors'><li>My foot hurts</li><li>You need a 
  #         hard hat</li></ul>"
  # 
  # Returns the html string.
  errorMessages: (errors) ->
    return "" unless errors
    return "<ul class='errors'><li>#{ errors.join("</li><li>") }</li></ul>"
  
  
  # Render javascript code to set the data for the client.
  # 
  # data - some JSON data to send to the client
  # 
  # Return some javascript code (String).
  jsData: (data) ->
    "window.data = #{ JSON.stringify data };"
  
  # Render the theme CSS.
  # 
  # Return some CSS (String).
  themeCSS: (theme=null) ->
    color.css (theme || "Idlefingers"),
      root:      "fractus"
      cursor:    "fractus-cursor"
      selection: "fractus-selection"
