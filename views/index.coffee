doctype 5
html ->
  head ->
    title 'Hi'
    link rel: 'stylesheet', href: 'style.css'

  body ->
    header ->
      h1 'Blog'
      div class: "tagline", -> "An arrangement of words."
      ol ->
        x = 0
        for post in @posts
          li ->
            h2 -> a href:"/entry/#{x}", class: "blog-title", -> post.title
            div class: "date", -> post.date
            div class: "detail", -> post.desc
          x += 1

      footer ->
        "This blog is open source."
