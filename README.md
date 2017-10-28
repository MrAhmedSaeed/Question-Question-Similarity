# Question-Question-Similarity
A Search Engine that will find the Similar questions against the new Question and return top ten similar questions.   

# IDEA
Question Similarity (QS): given the new question and a set of related questions from the collection, rank the similar questions according to their similarity to the original question (with the idea that the answers to the similar questions should be answering the new question as well)

# Description 
(System.R) contain the whole code of Search Engine.
The data is extracted from (Org_data.XML) file.
All Clean data is stored in (data.txt) file

System get a data from (data.txt) file then first apply preprocessing on them and then give the new question(query) to System/Search_engine.
System will return top 10 similar questions. I use TFIDF score to find a similarity between questions.

Result.xlxs contain top 10 docutments with their ID.
