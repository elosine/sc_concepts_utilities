Probability distributions

A probability distribution gives a relative weight to each available option in the space of possible outcomes; this is the probability density function (pdf). For a discrete set of possible outcomes, there is an explicit probability mass for each; for a continuous set (e.g., any number from the range 0.0 to 1.0) a mass can be associated with any interval. The sum of the probability density is normalized to 1.

From a probability density function we can create a cumulative distribution function (cdf) which allows us to  calculate which output we get on a particular occasion (particular roll of the dice).


//Helper functions for investigating pdfs and cdfs
(
//normalize total sum of an array to 1.0
~normalize = {|array|   array/(array.sum)}; //note, not safe if array is empty or otherwise sums to zero
//(could also use normalizeSum, just showing this explicitly)

//create array of cumulative values, assuming input is normalized (sums to 1.0)
~cumulative = {|array|
var num = array.size;
var accumulate = 0.0;
var cumul;

cumul = array.collect{|val, i|  var old= accumulate; accumulate = accumulate+val; old};

cumul
};

//use cumulative distribution to find an output value for an input
//assumes array is a cumulative distribution function, and array size is at least 1
~draw= {|input, array|
var nextindex;

nextindex= array.indexOfGreaterThan(input); //also see indexInBetween if want linearly interpolated index

//get nil if input greater than anything in array
if (nextindex.isNil,{nextindex= array.size;});

nextindex= nextindex-1; //get index before; we 'went past' and have to go one back to find the slot our input falls in

//nextindex should never be less than 0

nextindex/(array.size); //get position proportional within array length
}

)




Plotting approximations to different probability distributions:


//1. Uniform distribution, equal chance for any equal subsection of the range:

p= ~normalize.value(Array.fill(1000,1.0));

p.plot(minval:0.0, maxval:2.0/1000)  //pdf

c= ~cumulative.value(p);

c.plot	//cdf

Array.fill(1000,{ ~draw.value(1.0.rand, c)}).sort.plot //choose values; driven by uniform random number, could also just provide increasing uniform numbers from 0.0 to 1.0 (and then wouldn't need the sort)
//we do this a thousand times to simulate 'rolling the dice' many times; the distribution only really shows itself over many trials (and can do it more times for better approximations)

Array.fill(1000,{ 1.0.rand }).sort.plot //create values directly












//2. Linear distribution, probability density drops linearly, so more likely to get lower values:

p= ~normalize.value(Array.fill(1000,{|i| 1000-i}));

p.plot  //pdf

c= ~cumulative.value(p);

c.plot	//cdf

Array.fill(1000,{ ~draw.value(1.0.rand, c)}).sort.plot //choose values

Array.fill(1000,{ 1.0.linrand }).sort.plot //create values directly












//3. Negative exponential distribution, probability density drops exponentially, so much more likely to get lower values:


//there is a parameter here for the rate of fall off of the distribution
~alpha= 10.0;

p= ~normalize.value(Array.fill(1024,{|i| exp((i.neg/1024)*~alpha) }));

p.plot  //pdf

c= ~cumulative.value(p);

c.plot	//cdf

Array.fill(1000,{ ~draw.value(1.0.rand, c)}).sort.plot //choose values


//go back and try ~alpha= 100.0; note the quantisation caused by only working with arrays of limited size as we create a discrete approximation to the ideal continuous distribution













//4. Normal distribution (Gaussian)

//two parameters, mean ('centre') and standard deviation ('spread'); here we take sensible values to plot the distribution easily

~mu= 0.5; //mean
~sigma=  0.17; //standard deviation; most of probability mass within 3 standard deviations, so this makes the Gaussian fit the 0.0 to 1.0 range easily for our plotting; try changing these parameters later to see the effect.

//normalization constant calculated automatically, though there is a mathematical expression for it
p= ~normalize.value(Array.fill(1000,{|i|  exp((((i/1000)-~mu)/~sigma).squared.neg)}));

p.plot  //pdf

c= ~cumulative.value(p);

c.plot	//cdf

Array.fill(1000,{ ~draw.value(1.0.rand, c)}).sort.plot //choose values

Array.fill(1000,{  0.5.gauss(0.17).max(0.0).min(1.0)  }).sort.plot //create values directly, clamping within +-3 standard deviations











//5. Arbitrary distribution

//let's make up our own function

p= ~normalize.value(Array.fill(1024,{|i|  var prop= (i/1024.0); if(prop<0.2,{(0.2-prop)**(0.3)},{(prop-0.2)**2}) }));

p.plot  //pdf
p.size

c= ~cumulative.value(p);

c.plot	//cdf

Array.fill(1000,{ ~draw.value(1.0.rand, c)}).sort.plot //choose values


//example in use; 20 notes drawn using the custom distribution (0.0 to 1.0 range output rescaled to MIDI notes 48 to 72)
(
	{
		20.do{
			Synth(\acsound,[\freq, 48+(24*~draw.value(1.0.rand, c))]);
			//could quantise the notes to discrete pitches, e.g., with .round(1.0)

			0.25.wait;
		}
	}.fork;
)









There are many other interesting distributions you might investigate, see for example:
Charles Ames. A catalog of statistical distributions: Techniques for transforming random, determinate and chaotic sequences. Leonardo Music Journal, 1(1):55–70, 1991.
Denis Lorrain. A panoply of stochastic 'cannons'. Computer Music Journal, 41(1):53–81, 1980.




In practice, we often work with a relatively small discrete set of options. It is easy to create a custom probability distribution over a set:

[0,1,2,3,4,5].wchoose([0.2,0.3,0.1,0.1,0.05,0.25]) //make sure weights add to 1.0, or use normalizeSum


//examination using our machinery for pdf, cdf, and draws:
p= ~normalize.value([0.2,0.3,0.1,0.1,0.05,0.25]);

p.plot  //pdf

c= ~cumulative.value(p);

c.plot	//cdf

Array.fill(1000,{ ~draw.value(1.0.rand, c)*6}).sort.plot //choose values; multiply by 6 to get back integer indices





Strategies for Algorithmic Composition

-- Any machinery from mathematics/computer science/artificial intelligence is potentially applicable

-- Critical issues of musical representation; how to model music on a computer?

-- Building the model led by musicological analysis and intuition, or by more automated statistical analysis of a corpus

For discussion of different motivations and methodologies for the modeling of composition by computer, recommended you read:
Pearce, M., Meredith, D. and Wiggins, G. A. (2002) Motivations and Methodologies for Automation of the Compositional Process. Musicae Scientiae 6(2): 119-147






//for examples
(
SynthDef(\acsound,{|freq=440,amp=0.1,dur= 0.2,cutoff=2000|
var sound, filter;

sound= Saw.ar(freq, amp)*EnvGen.kr(Env([0,1,1,0],[0.01,0.05,(dur.max(0.07))-0.06]),doneAction:2);

filter= LPF.ar(sound,Line.kr(cutoff,300,dur));

Out.ar(0,filter.dup(2))
}).add;
)




Practical probability

See the accompanying 'Probability distributions' tutorial later for a more mathematical approach from first principles (skip it if it worries you). We'll use helper functions herein for now.

Probability is one of the great tools for algorithmic composition work. Rather than deterministic works, fixed given a starting state, we can create probabilistic works, different with every run.

(Actually, in truth, the random number generation we'll use depends on deterministic 'pseudo-random' functions in the background, cued from some factor like the current system time, but for our intents and purposes, they give the statistically legitimatised variation we seek).

A host of probabilistic functions are available in SuperCollider. We'll try some practically useful ones for algorithmic composition now, and also see the [Randomness] help file for some more hints, both language functions and UGens.




Probability theory allows selection from a space of options. Different options can have different chances of being chosen on any given 'roll of the dice'.

In the simplest form, choices amongst objects might be equally likely (equiprobable, uniform distribution):

//try these:
2.rand		//generates an integer, either 0 or 1

2.0.rand	//from 0.0 up to 2.0

2.rand2	// -2 to 2

2.0.rand2	//-2.0 to 2.0

rrand(2,4)	//range from 2 to 4, so one of 2,3,4

rrand(2.0,4.0)	//floating point range

[3,6,8,19].choose //choose one option from the Array

All these functions are making selections where the numbers in the range or options in the Array have an equal chance of turning up.













But the choices can also be weighted differently.

We might weight lower numbers as more likely than high:

1.0.linrand //linear distribution; not the same as uniform! Linearly decreasing weighting, so low numbers have more chance of turning up

Array.fill(1000,{linrand(1.0)}).sort.plot //see this visually by creating 1000 numbers using this generator, sorting them in order, then plotting the results


1.0.bilinrand //similar, goes between positive and negative 1.0, more weight towards 0 in all cases

Array.fill(1000,{bilinrand(1.0)}).sort.plot //see this visually


1.0.sum3rand //sum of 3 uniform random numbers between plus and minus 1.0 (will come out with more chance of numbers nearer 0, since values can cancel between positive and negative; in general, a sum of distributions tends to a centre-weighted normal distribution)

Array.fill(1000,{sum3rand(1.0)}).sort.plot //see this visually

//show similarity
Array.fill(1000,{({1.0.rand2}!3).sum * 0.33}).sort.plot //see this visually by creating 1000 numbers using this generator, sorting them in order, then


exprand(1.0,10.0)	//uniform choice, but over an exponentially mapped range, more likely to choose low


gauss(0.0,1.0) //famous bell-shaped Gaussian, normal distribution; has two parameters, mean and standard deviation. Most output values are within three standard deviations each side of the mean

Array.fill(1000,{gauss(0.0,1.0)}).sort.plot //see this visually

gauss(1.0,0.1) //mean 1.0, most output values within 0.3 (3*0.1) either side, so 0.7 to 1.3






Most often, you use arbitrary weights amongst a discrete set of options. Think of choosing amongst a set of possible MIDI notes, or dynamic levels, or durations.

[60,62,64,67].wchoose([0.5, 0.25, 0.2, 0.05]) //the first array is the array of options; the second is the array of weights

Array.fill(1000,{ [60,62,64,67].wchoose([0.5, 0.25, 0.2, 0.05]) }).sort.plot(minval:50, maxval:72) //see this visually

When you use wchoose, the array of weights has to add up to 1.0 (a standard feature of a probability distribution). There is a helper function for this:

[14, 3.7, 5.6, 8, 11].normalizeSum //make array add up to 1.0 by dividing by the sum of the entries





Finally, for rolls of the dice in decision making, the coin function is very useful:

0.5.coin //fair coin, equal chance of heads or tails: true or false as output

0.2.coin //unfair coin, 20% chance true

0.95.coin //unfair coin, 95% chance true




You can achieve a lot just with controlled use of probability distributions in this way.

You may also want to explore using different probability distributions at different points in time during a piece, perhaps by varying parameters in gauss, changing the weights for wchoose, or moving between entirely different functions. You can remap the values to different ranges at different points in time, or restrict which parts of a distribution you select from. We've seen similar ideas before in terms of time varying availability; e.g. 'tendency masks' in granular synthesis for allowed parameter ranges at different points in time.













Use of conditionals

Algorithmic music exploits the fundamental building blocks of computer algorithms. Conditional execution empowers computerised decision making; based on the current state, you can choose the next action in either a rigid deterministic way, or with (psuedo-)probabilistic choice.

//examples:
//deterministic
(
var pitch=60, amp=1.0;
if(pitch==60,{amp= 0.2});
amp
)

//probabilistic
(
var pitch=60, amp=1.0;
if(pitch==60 and: 0.5.coin,{amp= 0.2}); //amp gets set to 0.5 on average half the time
amp
)


In music, different states might correspond to:
-- different parameter settings for musical attributes (as above)
-- different playing modes ('mellow', 'aggressive', etc.)
-- different models of harmony, tonality, melody...
-- etc

One interesting analogy is the idea of a finite state machine as a model of computation: the computer has a set of program states it can be in, and at each step can transition to a variety of other states (including staying where it is).

It is for you to build the model of music; there are as many music theories as you want to explore. Of course, not all correspond well to existing 'styles' or 'genres', and there is much scope for experiment.









Conditional probability

If some event is known to have happened, this gives information about the situation which restricts what else may happen alongside it. Such reductions from a full choice within probability space to a more restricted area is the domain of conditional probability.

P (B | A) = P (A and B) / P (A)

where P (B | A) means the probability of B given that A is known to have happened.

If A is observed, to find P (B | A), look at the probability that both A and B can happen (the intersection of the areas of the probability space represented by A and B) relative to the probability of A happening in the first place.

(sidenote: Bayes theorem follows from the above, as P(B | A)= P(A | B) P(B)/P(A). Bayes theorem is useful for calculating one conditional probability in terms of another, ie A might be some observations and B a world state;  Bayes theorem lets us calculate the most likely world state, by looking at how each potential world state explains the observations)

We can also think about this in terms of an event observed a moment ago further constraining what could happen next:

P (B occurs at time n | A occurs at time n-1) = P (A at time n-1 and B at time n) / P (A occurs at time n-1)

In general, decisions can take account of not only the current situation, but the history of past states. We move away from '0th-order' systems where each choice is entirely independent of anything else that has happened.














Markovian systems

The idea of the current choice being dependent on past choices is encapsulated in a Markov system of order n, where n is the number of previous choices at stake. Simple Markov processes need to keep track of a larger and larger number of possibilities in a combinatorial explosion. Say there are 3 options at a given time, say, three notes to choose from:

[\a, \b, \c].choose	//0th order system, uniform selection

Now say that the choice depends on the choice just made, a 1st order system:

[\a, \b, \c].wchoose([0.7,0.2,0.1])   //if previously choose \a

[\a, \b, \c].wchoose([0.0,0.5,0.5])   //if previously choose \b

[\a, \b, \c].wchoose([0.1,0.4,0.5])   //if previously choose \c

Then in general there are 3*3= 9 probabilities to specify. For each increase in order, we'd gain another multiple of 3, so a second order Markov system requires 3*3*3 probabilities to be set up, and an Nth order needs 3**(N+1)

Higher order Markovian systems require exponentially bigger multi-dimensional matrices of probabilities.


//1st order Markov system example
(
var markovmatrix;
var currentstate=3.rand; //start in one of three states

markovmatrix= [
[0.7,0.2,0.1],
[0.0,0.5,0.5],
[0.3,0.4,0.3]
];


{
	20.do{
			Synth(\acsound,[\freq, [48,60,64].at(currentstate).midicps]);

			//which probability distribution to use depends on what state we're in right now
			currentstate = [0,1,2].wchoose(markovmatrix[currentstate]);

			0.25.wait;
			};

}.fork;
)


For fixed and variable order Markovian modeling see also the MathLib and ContextSnake Quarks.






Search

Search is a fundamental operation in computer algorithms. Musical parameterisations lead to combinatorially explosive search spaces, and issues of computational tractability. Heuristics are rules of thumb to cut down the amount of brute search by pruning the search tree.

Charles Ames differentiates:

comparative search: an exhaustive search through all options. Can find an optimal solution, but usually too computationally intensive

constrained search: finds a `good' solution by approximate methods, i.e., heuristics.

An early strategy (used back in 1955 by Hiller and Isaacson's) was generate and test. Random numbers are generated until they pass a test. The passed number becomes the latest choice, and a new selection is then made. Alternatively, we might restrict generations to only acceptable options in the first place (by heuristics).

More complicated strategies include back tracking (jumping back to an earlier decision point when a path has led to an impasse) and dynamic programming (greedy selection of the best option according to a cost function at any point, to comparison of multiple paths taking into account all steps but keeping down the proliferation of possible paths by only following best scoring paths to any given branching point).

You should see that any machinery from AI (whether GOFAI symbolic or connectionist) may be imported to problems of musical search.



//generate and test
(
var currentvalue= rrand(60,72);
var generateandtest;

generateandtest= {|previous=60|
	var number=rrand(24,127);
	var keeplooking;

	//keep searching until a number passes the tests
	while({

		keeplooking= false; //can only fail

		//note we could replace this test with just generating number in the allowable range to start with
		if (abs(number-previous)>12) {
			keeplooking= true;
		};

		//avoid certain intervals
		if (#[-5,-3,4,7,11].includes(number-previous)) {
			keeplooking= true;
		};

		((number.asString)++(if(keeplooking," rejected","accepted"))).postln;

		keeplooking
	},{
	//no need to do anything here, all done in while test function
	number=rrand(24,127);
	});

	number
};

{
	20.do{
			currentvalue = generateandtest.(currentvalue);

			Synth(\acsound,[\freq, currentvalue.midicps]);

			0.25.wait;
			};

}.fork;
)




Sonification of mathematics

Given the wonderful resources of mathematics, it's very tempting to translate mathematical structures into musical output. But be warned that the transformation does not often make perceptual sense, and can be very contrived. On the other hand, it may lead you to stimulating output you wouldn't otherwise have conceived.


//logistic map function used to generate pitch values
(
var currentvalue= 1.0.rand;
var logisticmap, r;

r=3.74;

logisticmap= {|previous=60|

	((1.0-previous)*previous*r).postln;
};

{
	50.do{
			currentvalue = logisticmap.(currentvalue);

			//must convert from the value in the range 0.0 to 1.0 to a musically useful pitch value
			//quartertones here
			Synth(\acsound,[\freq, (60+((currentvalue*12).round(0.5))).midicps]);

			0.125.wait;
			};

}.fork;
)


The example here demonstrates how the logistic map acts as a generator of values at the required rate for musical events set required, much as a UGen is a (usually much faster running) generator of sample values at audio rate. Analogous networks of number generation and modification (synthesis and processing) can be formed in algorithmic composition to determine musical parameter values for event streams.





We'll continue this next year in advanced computer music by discussing mappings and musical modeling in general. For example, we haven't touched here on data-driven modeling where a corpus is automatically analyzed to create a generative model. You may still approach such things intuitively, by formulating rules via your own personal analyses of musical style.






