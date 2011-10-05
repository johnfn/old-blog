doctype 5
html ->
  head ->
    title 'Hi'
    link rel: 'stylesheet', href: 'style.css'

  body ->
    h1 'Writing Club Fun!'
    ol ->
      h2 class: "blog-title", -> "Posts"

      for post in @posts
        li ->
          h3 -> a href: post.link, class: "blog-title", -> "post."
          div post.content
          span class: "date", -> post.date

    footer ->
      "This website is open source."
