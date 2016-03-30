# Development

first, cd into the folder with the html version of the experiment

compile index.coffee to formatted html, watch it and update when it changes

`coffeecup -f -w index.coffee`

start python server

`python3 -m http.server`

navigate to http://localhost:8000/

# Organization

CSS and JS that is free to use can be stored in the packages/ directory. All the code is in exp.coffee which is compiled and run in the browser. [Coffeecup](https://github.com/gradus/coffeecup) is used for templating.