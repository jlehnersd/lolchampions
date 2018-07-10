function documents = processtext(textData,champNames)

% tokenize the data to prepare for analysis
documents = tokenizedDocument(textData);

% remove champion names from data
name_S = strcat(champNames,"s");
documents = removeWords(documents,erasePunctuation(lower(champNames)));
documents = removeWords(documents,erasePunctuation(lower(name_S)));

% remove common words to reduce noise in the data
documents = removeWords(documents,stopWords);

% remove numeric text data
documents = regexprep(documents,'\d*','');

% normalize words to have same common root
documents = normalizeWords(documents);

return