require_relative './svd'

documents = [
  "human interface computer",
  "survey user computer system response time",
  "EPS user interface system",
  "system human EPS",
  "user time response",
  "trees",
  "trees graph",
  "trees graph minors",
  "survey graph minors"]

s = Svd.lsi(documents)
s.compute
s.print("rows.txt", "cols.txt", "log.txt")