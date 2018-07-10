function textData = gettextdata(rawData,preText,postText)

% gettextdata takes as input a string array of raw HTML code text rawData
%and character arrays preText and postText between which the desire text
% data is located, and gives as output a string array textData 

nChamps = numel(rawData);
textData = strings(141,1);
for iChamp = nChamps:-1:2
  champText = rawData(iChamp);
  textData(iChamp) = extractBetween(champText,preText,postText);
end

return