# Overview

This is a system for running an amazon mechanical turk experiment as simply as I know how. 

Nearly everything is written in [coffeescript](http://coffeescript.org/). If you're unfamiliar, coffeescript is "a little language that compiles into JavaScript". It's generally simpler, has a lot of handy tricks built in, and is compatible with any JS library. The entire language is described in that link above. The templating engine used is [coffeecup](https://github.com/gradus/coffeecup) which is just a very straightforward implementation of templating functions into coffeescript.

Browsers, of course, render HTML pages and run JS. So the first part of this puzzle is creating an html page that loads coffeescript and all the libraries we'll use. Once the browser has done that, we can run any coffeescript code directly, just like JS.

The code for the experiment is in exp.coffee. The experiment is organized into 'slides'. Each slide includes three functions: a coffeecup template for creating HTML, a function to run when the slide is created (e.g. to operate on any elements created by the template), and a function to run when the slide is closed. This is all taken care of by the `show_slide()` and `proceed()` functions.

# Development

The following command compiles index.coffee into, watches it and updates when it changes

`coffeecup -f -w index.coffee`

You probably won't have to change it much, though.

Also, for testing changes on your local machine, you can use a python server

`python3 -m http.server`

and then navigate to http://localhost:8000/ .

# Deployment

It is recommend to deploy this to a github project page (see https://pages.github.com/) like https://username.github.io/repository. This provides HTTPS for free.

The process involves creating a repository, creating a gh-pages branch on that repository and then committing your directory to the gh-pages branch. Once that's done the index.html file can be reached online at https://username.github.io/repository . The following code should work but I have not tested it.

```
git branch gh-pages
git checkout gh-pages
git commit -a -m 'add website branch'
```

# Testing

## General testing (local testing independent of MTurk)

General testing can be done by simply navigating to http://localhost:8000/ or the external URL after deployment. The default for each condition is to randomly select a single option for each between subject condition. When running the experiment (eg on MTurk) one can restrict the available conditions using a [query string](https://en.wikipedia.org/wiki/Query_string).

To do this, start by url encoding a list of the values. For instance, if you want the personal condition to select between the values "you have", "there is", "someone has" you will URL encode `'["you have", "there is", "someone has"]'` to get `%5B"you%20have"%2C%20"there%20is"%2C%20"someone%20has"%5D`. You can use Qurl to do this via the following lines executed in your browser console after loading the Qurl package

```
q = Qurl.create()
q.query('personal','["you have", "there is", "someone has"]')
q.query('valence','["sadness", "happiness", "doubt"]')
```

The result is your updated URL bar. Here's the general format

```
https://username.github.io/repository/?
personal=%5B"you%20have"%2C%20"there%20is"%2C%20"someone%20has"%5D
&valence=%5B"sadness"%2C%20"happiness"%2C%20"doubt"%5D
```

And instance, my specific url looks like

```
https://nickrsearcy.github.io/cause-affect-static/?
personal=%5B"you%20have"%2C%20"there%20is"%2C%20"someone%20has"%5D
&valence=%5B"sadness"%2C%20"happiness"%2C%20"doubt"%5D
```

## MTurk testing

There are a few things you'll want to test that are MTurk specific. Before anything else, run the entire experiment all the way through and make sure mmturkey sends you to a page called "turk.submit testing mode". This page looks at the JSON data you would be sending to MTurk. Make sure it includes everything you want. Also, in the subsequent tests, this is where you'll be looking to make sure it includes the data talked about.

### MTurk parameters

MTurk passes relevant information to your experiment through URL parameters. From the [external question documentation](http://docs.aws.amazon.com/AWSMechTurk/latest/AWSMturkAPI/ApiReference_ExternalQuestionArticle.html), this looks something like:

```
https://username.github.io/repository?
personal=%27%5B%22you+have%22%2C+%22there+is%22%2C+%22someone+has%22%5D%27
&valence=%27%5B%22sadness%22%2C+%22happiness%22%2C+%22doubt%22%5D%27
&assignmentId=123RVWYBAZW00EXAMPLE456RVWYBAZW00EXAMPLE
&hitId=123RVWYBAZW00EXAMPLE
&turkSubmitTo=https://www.mturk.com/
&workerId=AZ3456EXAMPLE
```

Test that URL and ensure that assignmentId, hitId, turkSubmitTo, and workerId are included in your turk.submit page.

### Preview

Replace the assignmentId with `ASSIGNMENT_ID_NOT_AVAILABLE` and make sure that your experiment loads a preview page correctly.

```
https://username.github.io/repository?
personal=%27%5B%22you+have%22%2C+%22there+is%22%2C+%22someone+has%22%5D%27
&valence=%27%5B%22sadness%22%2C+%22happiness%22%2C+%22doubt%22%5D%27
&assignmentId=ASSIGNMENT_ID_NOT_AVAILABLE
&hitId=123RVWYBAZW00EXAMPLE
&turkSubmitTo=https://www.mturk.com/
&workerId=AZ3456EXAMPLE
```

This is what turkers will see when they are deciding whether or not to accept your hit. Make sure it is accurate, informative, and succinct.

### Posting a hit to the sandbox

Below are the instructions for posting a HIT to MTurk. The instructions are the same if you are doing this to the main MTurk site or just the sandbox (a version of the MTurk site that functions exactly as the main one but for testing purposes and does not allow any actual money to change hands).

When you are ready to do this, you'll need your amazon credentials configured. Here's [boto's guide](http://boto.cloudhackers.com/en/latest/boto_config_tut.html) for that. I very highly recommend using the credentials file method. Whatever you do, **Do not hardcode the account key and secret key into your code**. If you do this in any version-controlled code, then anyone with access to the code has the keys to every $ you put on AWS. 

```
from boto.mturk.connection import MTurkConnection
from boto.mturk.question import ExternalQuestion
from boto.mturk.qualification import LocaleRequirement, PercentAssignmentsApprovedRequirement, Qualifications, NumberHitsApprovedRequirement


AK = "NOTAREALAK",
SK = "notarealsk",
HOST = "mechanicalturk.sandbox.amazonaws.com"
NUM_ITERATIONS = 100
EXPERIMENT_URL = """https://username.github.io/repository?
personal=%27%5B%22you+have%22%2C+%22there+is%22%2C+%22someone+has%22%5D%27
&valence=%27%5B%22sadness%22%2C+%22happiness%22%2C+%22doubt%22%5D%27
"""

mtc = MTurkConnection(host=HOST)

quals = Qualifications();
quals.add( PercentAssignmentsApprovedRequirement('GreaterThanOrEqualTo',95) )
quals.add( NumberHitsApprovedRequirement('GreaterThanOrEqualTo',1) )
quals.add( LocaleRequirement('EqualTo', 'US') )

new_hit = mtc.create_hit(
  hit_type=None,
  question = ExternalQuestion(EXPERIMENT_URL, 600),
  lifetime = 2*60*60, # Amount of time HIT will be available to accept unless 'max_assignments' are accepted before
  max_assignments = NUM_ITERATIONS,
  title = 'Cause and Affect',
  description = 'Participate in a simple psychological experiment on concept learning. The complete duration should be approximately 150s (reward is estimated according to $12/hr).',
  keywords = 'concepts, learning',
  reward = 0.75,
  duration = 15*60, # Maximum amount of time turkers are allowed to spend on HIT
  approval_delay = 1*60*60, # Amount of time after which HIT is automatically approved
  questions = None,
  qualifications = quals )[0]

print(new_hit.HITId)

```