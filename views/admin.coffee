doctype 5
html ->
  head ->
    title 'Hi'
    link rel: 'stylesheet', href: '/style.css'
    script src: 'showdown.js'

    coffeescript ->
      converter = new Showdown.converter()

      update = ->
        html = converter.makeHtml(document.getElementById("new-content").value)
        document.getElementById("rendered-content").innerHTML = html

      setInterval update, 100

  body ->
    h1 'Admin'
    form ->
      textarea id: "new-content"
      div id: "rendered-content", -> "Blah blah blah stuff harp"

      div -> input type:"submit", id: "submit-button", action: "post"

    footer ->
      "This blog is open source."
