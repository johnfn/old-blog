doctype 5
html ->
  head ->
    title 'Hi'
    link rel: 'stylesheet', href: '/style.css'
    script src: '/showdown.js'

    coffeescript ->
      converter = new Showdown.converter()

      update = ->
        html = converter.makeHtml(document.getElementById("new-content").value)
        document.getElementById("rendered-content").innerHTML = html

      setInterval update, 100

  body ->
    h1 'Add post'
    form method: "post", action: @action or "/admin", ->
      textarea name: "new-content", id: "new-content", ->
        @content or ""

      div id: "rendered-content", -> "Blah blah blah stuff harp"

      div -> input type: "text", name: "author", value: @author or "Your name"
      div -> input type: "submit", id: "submit-button"

    div "Some tips: *italic* **bold**"

    footer ->
      "This blog is open source."
