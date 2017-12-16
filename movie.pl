:-include('reviews.pl').
:-include('words.pl').

importance("sifat",0.9).
importance("zarf",0.8).
importance("isim",0.4).
importance("fiil",0.5).
importance("baglac",0.6).
importance("zamir",0.4).
importance("edat",0.3).

grades([1,2,3,4,5,6,7,8,9,10]).

% split the review to a list.
ayir(X,L):- split_string(X, " ", ",.!" , L).

%TESTING

%calculates average score of a review sentence.
sentence_score(Review, Grade) :- ayir(Review,List) , calculate_average_score(List,Grade).

%calculates average score of a sentence by dividing total score of words(numerator) and weighted sum of word categories(denominator).
calculate_average_score(List,Grade):- sentence_total_score(List,TotalScore), weighted_sum_of_categories(List, Denominator), Grade is TotalScore/Denominator.

%calculates the total score of a sentence (numerator).
sentence_total_score([],0).
sentence_total_score([H|T],TotalScore1) :- sentence_total_score(T,TotalScore2), word_weighted_score(H,Score), TotalScore1 is TotalScore2 + Score.

%finds category then multiplies the category importance with the training score of the word.
word_weighted_score(Word,Score):- class(Word,Category), importance(Category,Imp), training_score(Word,TrainingScore), Score is TrainingScore*Imp.

%calculates the weighted sum of categories 
weighted_sum_of_categories([],0).
weighted_sum_of_categories([H|T],Sum1) :-  weighted_sum_of_categories(T,Sum2), class(H,Category), importance(Category,Imp), Sum1 is Sum2 + Imp. 


%TRAINING

%train the knowledge base
train:- findall(Review,review(Review,_),ReviewList ),train_sentences(ReviewList).

%go through all reviews
train_sentences([]).
train_sentences([H|T]):- train_sentences(T), review(H,_),ayir(H,List), train_words(List).

%iterate over words of a sentence and assert new predicates
train_words([]).
train_words([H|T]):- train_words(T), word_score(H,Score), assert(training_score(H,Score)).

%calculates word's average score.
word_score(Word,Score):- total_grades(Word,TotalGrades,Occurence), Score is TotalGrades/Occurence.


%calculate total occurences of a word in reviews with given grade
number_of_grades(Word,Grade,Number):- \+review(Review,Grade) , Number is 0.   %if grade is not found in reviews number is 0
number_of_grades(Word , Grade , Number):-  findall(Review,review(Review,Grade),ReviewList), find_ocurrence(Word,ReviewList,Number).

%iterate over the list of reviews and find occurences
find_ocurrence(Word,[],0).
find_ocurrence(Word,[H|T],Number2) :- find_ocurrence(Word,T,Number1), ayir(H , List) , count_occurence(Word, List ,Number), Number2 is Number1 + Number.

%calculate words total grades (numerator of formula). 
total_grades(Word, TotalGrades,Occurence):-grades(L),calc_total_grades(Word, TotalGrades,L,Occurence).

%iterate over grade list and calculate total grades
calc_total_grades(Word,0,[],0).
calc_total_grades(Word,TotalGrades1,[H|T],Occurence1) :-  calc_total_grades(Word,TotalGrades2,T,Occurence2),number_of_grades(Word,H,Number), TotalGrades1 is TotalGrades2 + H*Number , Occurence1 is Occurence2 + Number.


%count the number of occurences of an item in a list
count_occurence(Word,[],0).
count_occurence(Word,[Word|T],Number1) :- count_occurence(Word,T,Number2) , Number1 is Number2 + 1.
count_occurence(Word,[H|T],Number) :- Word \= H , count_occurence(Word,T,Number).







