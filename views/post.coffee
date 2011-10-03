doctype 5
html ->
  head ->
    title 'Hi'
    link rel: 'stylesheet', href: '/style.css'

  body ->
    h1 'Blog Post'
    div class: "tagline", -> @title
    div -> @content

    footer ->
      "This blog is open source."
