$("#content").empty()



preview_template = ->
  div ".panel.panel-default", ->
    div ".panel-heading", ->
      h3 ".panel-title", -> "Preview of tiny HIT"
    div ".panel-body", ->
      p "This tiny HIT is designed to provide payment to people as simply as possible. Accept the HIT and then click the single button on the next screen. Thank you for your participation."

tiny_template = ->
  div ".panel.panel-default", ->
    div ".panel-heading", ->
      h3 ".panel-title", -> "Tiny HIT"
    div ".panel-body", ->
      p "Simply click the button below. Your HIT will automatically be approved very shortly."
      small "Thank you for your participation."
    button ".btn.btn-primary.btn-lg", type:"button",
            onclick:"turk.submit({'one':1})", "Submit"

template_to_render = if window.turk.previewMode then preview_template else tiny_template

$("#content").append(coffeecup.render(template_to_render))