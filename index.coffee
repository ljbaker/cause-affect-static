scripts = ["jquery-2.2.1.min.js", "jquery-ui.min.js", "bootstrap.min.js", "mmturkey.js",
          "underscore.min.js", "qurl.js", "coffee-script.js",
          "markdown-it.js", "coffeecup.js"]
styles = ["bootstrap.min.css", "bootstrap-theme.min.css", "jquery-ui.structure.min.css", "jquery-ui.theme.min.css"]

doctype 5
html ->
  head ->
    meta charset:"utf-8"
    title "Cause and Affect"
    link rel:"stylesheet", href:"packages/#{s}" for s in styles
    script src:"packages/#{s}" for s in scripts
  body ->
    div ".container", ->
      div ".col-sm-10", ->
        div "#main.well.well-lg", ->
          div "#content", ->
            h1 "Please wait while everything loads"
            p "Client-side coffeescript experiment"
            small "Everything written in beautiful coffeescript"
          button ".btn.btn-primary.btn-lg", type:"button",
            onclick:"proceed()", "Proceed"
    script type:"text/coffeescript", src:"exp.coffee"
