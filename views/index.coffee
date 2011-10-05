doctype 5
html ->
  head ->
    title 'Hi'
    link rel: 'stylesheet', href: 'style.css'
    script src: 'showdown.js'

    coffeescript ->
      converter = new Showdown.converter()

      markdownify = ->
        for elem in document.getElementsByTagName("li")
          html = converter.makeHtml(elem.innerHTML)
          elem.innerHTML = html

      setTimeout markdownify, 100

  body ->
    h1 'Writing Club Fun!'
    ol ->
      h2 class: "blog-title", -> "All Posts"

      for post in @posts
        li ->
          div post.content
          span class: "date", ->
            span -> "A post brought to you by " + post.author + " "
            a href: post.link, class: "blog-title", -> "(link) "
            a href: "edit" + post.link, class: "blog-title", -> "(edit)"

    a href: "/admin", -> "Add a post."

    footer ->
      "This website is open source."
