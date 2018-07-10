clear, clc, clf

% This script extracts text from the HTML code of the Riot Games website to
% form text vectors consisting of each ability for each champion (PQWER).

% -------------------------------------------------------------------------

% create file datastore (fds) of all champion webpage HTML text
fdsHTML = fileDatastore("*_RawText.txt",'ReadFcn',@customreader);
nChamps = numel(fdsHTML.Files);

% create a string array of HTML code text
champRawText = [];
while hasdata(fdsHTML)
    textHTML = read(fdsHTML);
    champRawText= [champRawText; textHTML]; %#ok<AGROW>
end

% declare string arrays for ability names and descritpions
passive = struct('Name',[],'Text',[]);
Q = struct('Name',[],'Text',[]);
W = struct('Name',[],'Text',[]);
E = struct('Name',[],'Text',[]);
R = struct('Name',[],'Text',[]);
 
% text proceeding and following names of champions and abilities
nameData = cell(6,1);
nNames = numel(nameData);

preNameText = {'<title>';
               'passive.name">';
               'spells.0.name">';
               'spells.1.name">';
               'spells.2.name">';
               'spells.3.name">'};
             
postNameText = {' | ';
                '</h3>';
                '</h3>';
                '</h3>';
                '</h3>';
                '</h3>'};
               
% extract champion and ability names from HTML code text
for iName = 1:nNames
  preText  = preNameText{iName};
  postText = postNameText{iName}; 
  nameData{iName} = gettextdata(champRawText,preText,postText);
end

champion.Name = nameData{1};
passive.Name = nameData{2};
Q.Name = nameData{3};
W.Name = nameData{4};
E.Name = nameData{5};
R.Name = nameData{6};

% upload champion classes from premade text file
fileID = fopen('classlistbasic.txt');
classes = textscan(fileID,'%s');
fclose(fileID);
champion.Class = string(classes{1});

% manually enter Aatrox name data due to different HTML code
champion.Name(1) = "Aatrox";
passive.Name(1) = "Deathbringer Stance";
Q.Name(1) = "The Darkin Blade";
W.Name(1) = "Infernal Chains";
E.Name(1) = "Umbral Dash";
R.Name(1) = "World Ender";

% text proceeding and following ability descriptions
abilityData = cell(5,1);
nAbilities = numel(abilityData);
useSimplifiedText = false;

if ~useSimplifiedText
preAbilityText  = {'passive.description">';
                   'spells.0.tooltip" data-transforms="parse_tooltip">';
                   'spells.1.tooltip" data-transforms="parse_tooltip">';
                   'spells.2.tooltip" data-transforms="parse_tooltip">';
                   'spells.3.tooltip" data-transforms="parse_tooltip">'};
                 
postAbilityText = {'.</p>';
                   '</p></div></div></div><div id="QVideoDiv';
                   '</p></div></div></div><div id="WVideoDiv';
                   '</p></div></div></div><div id="EVideoDiv';
                   '</p></div></div></div><div id="RVideoDiv'};
else
preAbilityText  = {'passive.description">';
                   'spells.0.description">';
                   'spells.1.description">';
                   'spells.2.description">';
                   'spells.3.description">'};
                 
postAbilityText = {'</p>';
                   '</p>';
                   '</p>';
                   '</p>';
                   '</p>'};
end
  

% extract ability descriptions from HTML code text
for iAbility = 1:nAbilities
  preText  = preAbilityText{iAbility};
  postText = postAbilityText{iAbility}; 
  abilityData{iAbility} = gettextdata(champRawText,preText,postText);
end

passive.Text = abilityData{1};
Q.Text = abilityData{2};
W.Text = abilityData{3};
E.Text = abilityData{4};
R.Text = abilityData{5};

% manually enter Aatrox name data due to different HTML code
passive.Text(1) = "Aatrox deals bonus damage on his next attack and reduces heals and shields on the target.";
if ~useSimplifiedText
  Q.Text(1) = "Aatrox slams his greatsword down, dealing physical damage. The Darkin Blade may be re-cast 2 additional times, each one increasing in damage. Each strike can hit with the Edge, briefly knocking enemies up and dealing more damage.";
  W.Text(1) = "Aatrox smashes the ground, dealing physical damage to the first enemy hit and slowing.Champions or Large Monsters have to leave the impact area or be dragged back and damaged again.";
  E.Text(1) = "Passive: Aatrox heals for % of physical damage he deals. Active: Aatrox lunges, briefly gaining Attack Damage. 2 charges.";
  R.Text(1) = "Aatrox reveals his true demonic form for the next seconds, fearing nearby minions and gaining: Increased movement speed for the first 1 second, and when not in combat with champions or turrets. Increased Attack Damage. A Blood Well that steadily stores health, allowing him to Revive if he takes lethal damage.";
else
  Q.Text(1) = "Aatrox slams his greatsword down, dealing physical damage. He can swing three times, each with a different area of effect.";
  W.Text(1) = "Aatrox smashes the ground, dealing damage to the first enemy hit. Champions and large monsters have to leave the impact area quickly or they will be dragged to the center and take the damage again.";
  E.Text(1) = "Aatrox lunges, gaining attack damage.";
  R.Text(1) = "Aatrox unleashes his demonic form, gaining attack damage and movement speed. Upon taking lethal damage, Aatrox will revive instead of dying, healing for a percentage of his maximum health.";
end

% combine text from all 5 abilities into one string for each champion
for iChamp = nChamps:-1:1
  passive_ = passive.Text(iChamp);
  Q_ = Q.Text(iChamp);
  W_ = W.Text(iChamp);
  E_ = E.Text(iChamp);
  R_ = R.Text(iChamp);
  champion.rawTextData(iChamp) = strcat(passive_," ",Q_," ",W_," ",E_," ",R_," ");
end
champion.cleanTextData = champion.rawTextData;

% remove any remaining HTML code
champion.cleanTextData = eraseTags(champion.cleanTextData);

% remove punctuation
champion.cleanTextData = erasePunctuation(champion.cleanTextData);

% convert all characters to lowercase
champion.cleanTextData = lower(champion.cleanTextData);

%------------
% create class categories for analysis
champion.Class = categorical(champion.Class);
figure
h = histogram(champion.Class);
xlabel("Class")
ylabel("Frequency")
title("Class Distribution")


%------------
% obtain class prediction accuracy for 100 random partitions
nTests = 50;
acc = zeros (nTests,1);
for iTest = 1:nTests
% randomly partition data for classification training and testing
cvp = cvpartition(champion.Class,'Holdout',0.15);

% extract text data and class labels
textDataTrain = champion.cleanTextData(cvp.training);
textDataTest = champion.cleanTextData(cvp.test);
YTrain = champion.Class(cvp.training);
YTest = champion.Class(cvp.test);

%------------
% process text data to be suitable for analysis

% tokenize the data to prepare for analysis
documents = processtext(textDataTrain,champion.Name);

%------------
% create bag-of-words model and remove words that appear no more than twice
bag = bagOfWords(documents);
bag = removeInfrequentWords(bag,2);

% construct the classification mdoel based on the training text data
XTrain = bag.Counts;
%mdl = fitcecoc(XTrain,YTrain,'Learners',templateLinear('Solver','lbfgs'));
mdl = fitcecoc(XTrain,YTrain,'Learners','linear');

%------------
% process the test text data for classification analysis
documentsTest = processtext(textDataTest,champion.Name);
XTest = encode(bag,documentsTest);

% predict champ classes of test data based on the model from train data
YPred = predict(mdl,XTest);
acc(iTest) = sum(YPred == YTest)/numel(YTest);

end

accmean = mean(acc)
accsd   = std(acc)


% -------------------------------------------------------------------------
% use fscan to capture every character in the HTML text file
function data = customreader(filename)
%maxReadSize = 2^10;
fileID = fopen(filename);
data_ = textscan(fileID,'%s','whitespace','','delimiter','\n');
fclose(fileID);
data = strjoin(string(data_{1}));
end