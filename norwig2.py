# original by Peter Norwig
import collections
import re
def wordcount(filename, n=10):
   text = open(filename).read().lower()
   counts = collections.Counter(re.findall('[\!-\~]+', text))
   for i, w in counts.most_common():
      print(i, w)

wordcount("kjvbible_x10.txt")
