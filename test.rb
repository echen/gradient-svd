require_relative './svd'

documents = [
  "human interface computer",
  "computer user system response time survey",
  "interface user system EPS",
  "human system EPS",
  "user response time",
  "trees",
  "trees graph",
  "trees graph minors",
  "survey graph minors"]

s = Svd.lsi(documents)
s.compute
s.print("rows.txt", "cols.txt", "log.txt")