doctype 5
html ->
  head ->
    title 'Hi'
    link rel: 'stylesheet', href: 'style.css'

  body ->
    h1 'Blog'
    div class: "tagline", -> "An arrangement of words."
    ol ->
      for section in ["Posts", "Stuff"]
        h2 class: "blog-title", -> section
        x = 0
        for post in @posts
          li ->
            h3 -> a href:"/entry/#{x}", class: "blog-title", -> post.title
            span class: "date", -> post.date
          x += 1

    footer ->
      "This blog is open source."
