# Latent Semantic Indexing Example

To use the latent semantic indexing feature, create an array of documents, and pass it to the `Svd.lsi` method. To print out the document and word features, call the `print` method. Here is an example (taken from the Deerwater et al. paper):

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
	
We can then read the features into R and plot them:

  d = read.table("rows.txt")
	colnames(d) = c("name", "x", "y")
	qplot(x, y, data = d, label = name, size = 3, geom = "text")
	
![Row Vectors](https://img.skitch.com/20110304-rcagbqb6nh7sq4pw93jw729ewi.jpg)