show_slide = (slide_obj, proceed=true, clear=true) ->

  _.defaults(slide_obj,{
    template: ->
      h1 "hello default template"
      p "replace me"
    name: "no name"
    function: ->
      console.log("we have executed a default slide function for slide #{this.name}")
    })

  @exp.slide_history.push({
    "name": slide_obj["name"]
    "time": new Date().getTime()
    })

  if clear
    $("#content").empty()

  $("#content").append(coffeecup.render(slide_obj.template, personal: @exp.personal, valence: @exp.valence, chemical: @exp.chemical))

  slide_obj.function()

@proceed = ->
  current_slide = @exp.slides[@exp.slide_index] 
  if @exp.slide_index > -1 and current_slide["close"]
    current_slide.close()
  num_slides = @exp.slides.length
  @exp.slide_index = _.min([@exp.slide_index+1,num_slides-1])
  show_slide(@exp.slides[@exp.slide_index])

intro_template = ->
  # p "this is a test"
  h1 -> "Informed consent"
  p -> "Please read over the following informed consent agreement."
  div ".panel.panel-default", ->
    div ".panel-heading", ->
      h3 ".panel-title", "Informed Consent: Studies of Concept Learning On-line"
    div ".panel-body", style:"height:200px;overflow:auto", ->
      a = $.get({
        url: "consent.md"
        async: false
        })
      markdownit().render(a.responseText)
  h1 -> "Introduction"
  p -> "In a moment you will be asked to read a brief scenario. You will then be asked to make a few judgments based on this scenario."
  p -> "Please pay close attention and answer to the best of your abilities."

intro =
  name: "introduction"
  template: intro_template

instructions = 
  name: "instructions"

training_template = ->
  div ".panel.panel-default", ->
    div ".panel-heading", ->
      h3 ".panel-title", "Description"
    div ".panel-body", ->
      p "Imagine you learn that #{window.exp.personal} a rare gene which, when activated, results in an increase in #{window.exp.valence}. You learn about research investigating the effect of an experimental drug on the activation of this gene."
      p "Of course, the gene may only be activated in persons who possess the gene. Of those who have the gene, the gene may sometimes be activated without the drug. Also, some drugs may have a large effect on gene activation, some may have a small effect, and others, no effect. Thus, a group of people who did not recieve the drug were also checked to see if they had activated the same gene as those who did recieve the drug."
  for c,i in window.exp.chemical
    div ".panel.panel-default", ->
      div ".panel-heading", ->
        h3 ".panel-title", "Chemical ##{i+1}"
      div ".panel-body", ->
        table ".table.table-bordered", ->
          tr ->
            td ""
            td -> strong -> "Gene activated"
            td -> strong -> "Gene not activated"
          tr ->
            td -> strong -> "Recieved drug"
            td -> "#{c[0]}"
            td -> "#{100-c[0]}"
          tr ->
            td -> strong -> "Did not recieve drug"
            td -> "#{c[1]}"
            td -> "#{100-c[1]}"
        p -> "In the experimental group, the gene was found to be activated in #{c[0]} out of 100 subjects. In the control group, the gene was found to be activated in #{c[1]} out of 100 subjects."
        p -> "Using the slider below, evaluate these results. The 0 indicates that the drug <strong>never causes</strong> the gene to be activated and the 10 indicates that it <strong>always causes</strong> the gene to be activated."
        div ".slider-label", align:"center", ->
          span "Evaluation:"
          input ".slider", type:"text", id:"input-#{i}", style:"border:0; font-weight: bold;", c:"#{c}"

        div align:"center", style:"text-align: center; width:100%", ->
          div ".container-fluid", ->
            div ".row", ->
              div ".col-sm-1", -> "<b>never</b>"
              div ".col-sm-8", -> div "#slider-#{i}", ""
              div ".col-sm-1", -> "<b>always</b>"

training_function = ->
  for c,i in window.exp.chemical
    # console.log("we can at least say slider-#{i}")
    $("#slider-#{i}").slider({
      value: 5,
      min: 0,
      max: 10,
      step: 1,
      slide: (event, ui) -> 
        index = event.target.id.split("-")[1]
        $("#input-#{index}").val( ui.value ) })

training_close = ->
  input = []
  for i in _.range(10)
    input.push({
      c: $("#input-#{i}").attr("c")
      value: $("#input-#{i}").val()
      })
  window.exp.training_input = input

training = 
  name: "training"
  template: training_template
  function: training_function
  close: training_close

survey_template = ->
  div ".panel.panel-default", ->
    div ".panel-heading", ->
      h3 ".panel-title", -> "Validation"
      small "required"
    div ".panel-body", ->
      p -> "Select the number that corresponds to 'the experimental drug <em>never causes</em> the gene to be activated'."
      p -> 
        select ".form-control", id:"q0", ->
          for i in _.range(11)
            if i==5
              option selected="selected", -> "#{i}"
            else
              option -> "#{i}"
      p -> "Select the number that corresponds to 'the experimental drug <em>never causes</em> the gene to be activated'."
      p -> 
        select ".form-control", id:"q1", ->
          for i in _.range(11)
            if i==5
              option selected="selected", -> "#{i}"
            else
              option -> "#{i}"
  div ".panel.panel-default", ->
    div ".panel-heading", ->
      h3 ".panel-title", -> "Improve our experiment"
    div ".panel-body", ->
      p -> "How clear did you find the instructions for the experiment?"
      p -> 
        select ".form-control", id:"q2", ->
          for i in _.range(11)
            if i==5
              option selected="selected", -> "#{i}"
            else
              option -> "#{i}"
      p -> "Let us know if you have any other questions or comments."
      p -> 
        textarea ".form-control", id:"q3", rows="3", ->
          
survey_close = ->
  input = []
  for i in _.range(4)
    input.push({
      q: "q#{i}"
      value: $("#q#{i}").val()
      })
  window.exp.survey_input = input

  window.exp.slide_history.push({
    "name": "exit"
    "time": new Date().getTime()
    })

  window.turk.submit(window.exp)


survey =
  name: "survey"
  template: survey_template
  close: survey_close

preview_template = ->
  div ".panel.panel-default", ->
    div ".panel-heading", ->
      h3 ".panel-title", -> "Preview"
    div ".panel-body", ->
      p "Hello, this is a quick experiment that measures how people make evaluations in different contexts. The experiment is expected to last about 4 minutes and the reward has been calculated to provide the equivalent of $10/hour."

preview =
  name: "preview"
  template: preview_template

# attach exp to window, it'll be what we use to keep track of experiment data.
@exp = {}
@exp.slide_index = -1 # start at -1 so that the first slide shown is at 0
@exp.slides = [
  intro,
  training,
  survey,
]
@exp.slide_history = []
_.extend(@exp,turk)

# in order to generate the desired query string do the following in a browser console where the Qurl package is loaded
# u = Qurl.create(); u.query("personal", '["you have","there is","someone has"]'); u.query("valence", '["sadness", "happiness", "doubt"]')

querystring = Qurl.create().query()
_.defaults(querystring,{
  personal: '["you have","there is","someone has"]',
  valence: '["unhappiness", "skill in stenography", "happiness", "pagally", "sadness", "positivity", "contentment", "pessimism", "gloominess", "centeredness", "doubt"]',
  chemical: '[[10, 10], [40, 10], [40, 40], [60, 10], [60, 40], [60, 60], [90, 10], [90, 40], [90, 60], [90, 90]]'
  })

for key in ["personal", "valence", "chemical"]
  value = querystring[key]
  new_value = JSON.parse(value)
  querystring[key] = new_value

@exp.valence_conditions = querystring.valence
@exp.valence = _.sample(@exp.valence_conditions)
@exp.personal_conditions = querystring.personal
@exp.personal = _.sample(@exp.personal_conditions)
@exp.chemical = _.shuffle(querystring.chemical)

if @exp.previewMode
  @exp.slides = [preview]

@proceed()
