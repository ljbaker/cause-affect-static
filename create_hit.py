from boto.mturk.connection import MTurkConnection
from boto.mturk.question import ExternalQuestion
from boto.mturk.qualification import LocaleRequirement, PercentAssignmentsApprovedRequirement, Qualifications, NumberHitsApprovedRequirement
from config import AK,SK

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
