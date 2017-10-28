install.packages("tm")  
install.packages("SnowballC") 
install.packages("wordcloud") 
install.packages("RColorBrewer") 
install.packages("stringi")
install.packages("RWeka")
install.packages("tau")
install.packages("NLP")
install.packages("xlsx")

library("NLP")
library("tau")
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
library("RWeka")
library("xlsx")


#Read data from data.txt file
filePath <- ("C:/Users/Ahmed/Documents/R/data.txt")
text <- readLines(filePath)
#create a query 
query <- "where i can buy a oil for massage?"

#merge query with original data
docs.list <- Corpus(VectorSource(text))
N.docs <- length((docs.list))
names(docs.list) <- paste0("doc", c(1:N.docs))
query <- Corpus(VectorSource(query))
my.docs <- VectorSource(c(docs.list, query))
my.docs$Names <- c(names(docs.list), "query")

#make a corpus that contain both query and data
docs <- Corpus(my.docs)

#Preprocessing
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")

# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower))
# Remove numbers
docs <- tm_map(docs, removeNumbers)
# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))
# specify your stopwords as a character vector
docs <- tm_map(docs, removeWords, c("blabla1", "blabla2")) 
# Remove punctuations
replacePunctuation <- content_transformer(function(x) {return (gsub("[[:punct:]]"," ", x))})
docs <- tm_map(docs, replacePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)
# Text stemming
#docs <- tm_map(docs, stemDocument)

BigramTokenizer <-function(x)
    unlist(lapply(ngrams(words(x), 2), paste, collapse = " "), use.names = FALSE)

tdm <- TermDocumentMatrix(docs, control = list(tokenize = BigramTokenizer))
#options(mc.cores=1)
#tokenize_ngrams <- function(x, n=2) return(rownames(as.data.frame(unclass(textcnt(x,method="string",n=n)))))
#tdm<-TermDocumentMatrix(docs,control=list(tokenize=tokenize_ngrams))
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
tdm<-TermDocumentMatrix(docs, control = list(tokenize = BigramTokenizer))
#tdm <- TermDocumentMatrix(docs)
tdm<-removeSparseTerms(tdm, 0.995)
tf <- as.matrix(tdm)
idf <- log( ncol(tf) / ( 1 + rowSums(tf != 0) ) )
tf_idf <- tf*idf
#check
tfidf.matrix <- scale(tf_idf, center = FALSE, scale = sqrt(colSums(tf_idf^2)))

query.vector <- tfidf.matrix[, (N.docs + 1)]
tfidf.matrix <- tfidf.matrix[, 1:N.docs]
doc.scores <- t(query.vector) %*% tfidf.matrix

#textcontent
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
docs.list <- tm_map(docs.list, toSpace, "/")
docs.list <- tm_map(docs.list, toSpace, "@")
docs.list <- tm_map(docs.list, toSpace, "\\|")

# Convert the text to lower case
docs.list <- tm_map(docs.list, content_transformer(tolower))
# Remove numbers
docs.list <- tm_map(docs.list, removeNumbers)
# Remove english common stopwords
docs.list <- tm_map(docs.list, removeWords, stopwords("english"))
# Remove your own stop word
# specify your stopwords as a character vector
#docs <- tm_map(docs, removeWords, c("blabla1", "blabla2")) 
# Remove punctuations
replacePunctuation <- content_transformer(function(x) {return (gsub("[[:punct:]]"," ", x))})
docs.list <- tm_map(docs.list, replacePunctuation)
# Eliminate extra white spaces
docs.list <- tm_map(docs.list, stripWhitespace)


textcontent<-data.frame(text=unlist(sapply(docs.list, `[`, "content")), stringsAsFactors=F)
row.names(textcontent)<-NULL

results.df <- data.frame(doc = names(docs.list), score =t(doc.scores), text = textcontent)
results.check <- results.df[order(results.df$score, decreasing = TRUE), ]
write.xlsx(results.check, "C:/Users/Ahmed/Documents/R/result.xlsx")
results.check1<-results.check[1:10,]
rm(list = ls())

