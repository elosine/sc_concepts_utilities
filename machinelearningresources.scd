//Some Machine Learning Resources: SuperCollider Classes and UGens


In the Quarks: 

MathLib //Multiuple authors: including MarkovSet and FuzzySet classes as well as generally useful maths support for matrices and more

ContextSnake //Gerhard Nierhaus, Alberto de Campo: A Markov pattern with variable context depth

KDTree		//Dan Stowell: a data structure for faster search through a large set of multidimensional feature vectors (e.g., useful for concatenative synthesis with a database of such vectors as tags)

KMeans		//Dan Stowell: basic unsupervised clustering algorithm


NatureToolkit //Batuhan Bozkurt's GA, L system, and Cellular Automata classes
There have also been Genetic Algorithm (GA) projects by the likes of Fredrik Olofsson, Dan Stowell, Matthew Yee-King




Dan Stowell's MCLD UGens (in the sc3-plugins, http://sourceforge.net/projects/sc3-plugins/) contain some server side learning algorithms: 
SOMTrain  		//self-organizing map (data dimensionality reduction tool)
GaussClass		//Gaussian classifier



Chris Kiefer and my NeuralNet class, and external program for speeding up training: 
http://ck13.net/?page_id=35
Chris has also created a class for CTRNNs: Continuous-Time Recurrent Neural Networks




Some from my website: http://www.sussex.ac.uk/Users/nc81/code.html#SC
Reinforcement learning classes, such as for the SARSA (state-action-reward-state-action) algorithm

Also in the SCMIR Library: 
GMM //Gaussian Mixture Model (relies on provided external program)
NaiveBayes
MarkovModel //another implementation, fixed order
PPMC //Prediction by Partial Match algorithm C; a variable order Markov Model



There are some manifestations of machine learning algorithms built within synthesis UGens, such as KmeansToBPSet1 in the SLUGens, or MarkovSynth by Batuhan Bozkurt.

Machine learning is a broad field, and there are overlaps with other algorithms, such as information theoretic relations between symbol trained algorithms like MarkovModels, and predictive/compression algorithms like Linear Predictive Coding or Lempel-Ziv (in the Quark redSys by Fredik Olofsson, there are implementations of many compression algorithms). 







