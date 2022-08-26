%% GENDER STEREOTYPES AND SEMANTIC CATEGORIZATION IN A PRIMING PARADIGM
% Authors: Jakob Weickmann, Boryana Todorova (20200216)
%% Description
% This experiment about visual perception tests whether stereotypes about
% men or women affect the reaction time in a task, where the participant
% has to discriminate adjectives according to their valence. Primes are
% masculine and feminine faces that are either happy or angry-looking. 
% After the experiment is a rating task to control for individual
% differences in the perception of the target stimuli. 

%% Setup
% Clear everything
clear all;
close all;
clear mex;
clear mem;
sca;
clc;

%% Screen Setup
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
rng('shuffle');

% disable syn tests when coding/debugging but not when running experiments!!
Screen('Preference', 'SkipSyncTests', 1); 

% Checking Psychtoolbox: Break and issue an eror message if installed 
% Psychtoolbox is not based on OpenGL or Screen() is not working properly.
AssertOpenGL; 

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer (only 1 screen? this will be 0).
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen.
screenNumber = max(screens);

% Get black and white for your system.
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Get medium gray.
gray = [127 127 127];

% Define background color when opening window.
bgColour = gray;

%% Trial Matrix
% Adjectives | Happy Female Face | Aggressive Female Face | Happy Male Face | Aggressive Male Face
% -----------|-------------------|------------------------|-----------------|---------------------
% positive   | congruent         | incongruent            | congruent       | incongruent
% negative   | incongruent       | congruent              | incongruent     | congruent


%% Conditions, Blocks/Trials order
% number of blocks
nBlocks = 5;

% number of conditions: 2 (Gender of Face) x 2 Happy/Aggressive) x 2 (positive/negative adjective) = 8
nConditions = 8;

% number of Trials per block
TrialsPerCondition = 8;
nTrials = TrialsPerCondition * nConditions;

% create a trial matrix from which to select on each trial
TrialMat =      randperm(nTrials);                          % trial number
TrialMat(2,:) = [ones(1,nTrials/4) 2*ones(1,nTrials/4),... 
                 3*ones(1,nTrials/4) 4*ones(1,nTrials/4)];  % Face type
TrialMat(3,:) = [ones(1,nTrials/8) 2*ones(1,nTrials/8),...
                 ones(1,nTrials/8) 2*ones(1,nTrials/8),...
                 ones(1,nTrials/8) 2*ones(1,nTrials/8),...
                 ones(1,nTrials/8) 2*ones(1,nTrials/8)];    % Adjective Valence
                          
TrialMat =  sortrows(TrialMat');  
TrialMat =  TrialMat';

%% Load images
angry_man = imread('images/angry_man_small.png'); 
angry_woman = imread('images/angry_woman_small.png');
happy_man = imread('images/happy_man_small.png');
happy_woman = imread('images/happy_woman_small.png');

%% Scramble images
blockSize = 2; % size of the resulting blocks
nRows = size(angry_man, 1) / blockSize; % number of rows for scrambling
nCols = size(angry_man, 2) / blockSize; % number of colums for scrambling

scrambled_images = {};

% Turn images into cell arrays
scrambled_angry_man = mat2cell(angry_man, ones(1, nRows) * blockSize, ones(1, nCols) * blockSize, size(angry_man, 3));
scrambled_angry_woman = mat2cell(angry_woman, ones(1, nRows) * blockSize, ones(1, nCols) * blockSize, size(angry_woman, 3));
scrambled_happy_man = mat2cell(happy_man, ones(1, nRows) * blockSize, ones(1, nCols) * blockSize, size(happy_man, 3));
scrambled_happy_woman = mat2cell(happy_woman, ones(1, nRows) * blockSize, ones(1, nCols) * blockSize, size(happy_woman, 3));

% Rearrange the cell arrays (=Scrambling)
scrambled_angry_man = cell2mat(reshape(scrambled_angry_man(randperm(nRows * nCols)), nRows, nCols));
scrambled_angry_woman = cell2mat(reshape(scrambled_angry_woman(randperm(nRows * nCols)), nRows, nCols));
scrambled_happy_man = cell2mat(reshape(scrambled_happy_man(randperm(nRows * nCols)), nRows, nCols));
scrambled_happy_woman = cell2mat(reshape(scrambled_happy_woman(randperm(nRows * nCols)), nRows, nCols));

%% Load verbal stimuli
% Loading the data
% Rocklage, M. D., & Fazio, R. H. (2015). 
% The Evaluative Lexicon: Adjective use as a means of assessing and distinguishing attitude valence, extremity, and emotionality. 
% Journal of Experimental Social Psychology, 56, 214?227. https://doi.org/10.1016/j.jesp.2014.10.005
load('target.mat'); % 37x2 cell array (1st row positively valenced, 2nd row negatively valenced)

%% Get the participant's details
prompt = {'Subject number (integer):','Subject Initials:', 'Age:', 'Gender (f/m/d or leave empty):', 'Handedness (L/R/0):'};
title = 'Please enter the participant''s details';
dims = [1 20; 1 15; 1 10; 1 40; 1 30];
definput = {'1','A.B.', '99', '', 'R'};
answer = inputdlg(prompt,title,dims,definput);
subjectCode = answer{1};
[num, sub, age, gender, hand] = deal(answer{:}); % store answers in separate variables

subNum = str2double(num); % convert Subject number from string to number if needed
subInfo = [{'Subject Number'}, {'Name'}, {'Sex'}, {'Age'}, {'Handedness'};...
    {num}, {sub}, {age}, {gender}, {hand}]; % store together in a single variable
    
%% Open on-screen window
% [windowPtr, windowRect] = Screen('OpenWindow', screenNumber, bgColour);
% Open a fullscreen window using Screen('OpenWindow'). This returns a
% window handle (windowPtr) and the coordinates of the window 
% (windowRectrect). 

screenRect = [];
[windowPtr, windowRect] = Screen('OpenWindow', screenNumber, bgColour, screenRect);

% Retreive the maximum priority number
topPriorityLevel = MaxPriority(windowPtr);

% set priority level for accurate timing
Priority(topPriorityLevel);

%% Experiment Parameters: Text, Stimuli, Durations
% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', windowPtr);

% durations in frames
fDur = round(0.500/ifi); % numbers are in seconds
gDur = round(0.200/ifi); 
pDur = round(0.050/ifi);
tDur = round(1.000/ifi);
rDur = round(2.000/ifi);
mDur = round(0.050/ifi); 
iDur = round(1.000/ifi);

% durations in seconds
fixDur      = ifi * (fDur-0.5); % duration of fixation point
greenDur    = ifi * (gDur-0.5); % duration of green fixation point
primeDur    = ifi * (pDur-0.0); % duration of prime (face)
targetDur   = ifi * (tDur-0.5); % target duration (adjective)
maskDur     = ifi * (mDur-0.5); % masking duration
respDur     = ifi * (rDur-0.5); % response window after target
iti         = ifi * (iDur-0.5); % inter trial interval

% location coordinates (rects)
% center coordinates
xCenter = windowRect(3)/2;
yCenter = windowRect(4)/2;

% stimulus sizes in pixels
fixRadius = 10;
primeRadius = 400;

% coordinate rects
fixRect =           [xCenter - fixRadius, yCenter - fixRadius,...
                     xCenter + fixRadius, yCenter + fixRadius];
     
targetRect_Center = [xCenter - primeRadius, yCenter - primeRadius,...
                     xCenter + primeRadius, yCenter + primeRadius];

%% Instructions
% Instructions for odd participants (invert the keys that need to be
% pressed)
if rem(subjectCode,2) ~= 0
    instructions = ['--> PRESS ''<color=00ff00>X<color>'' ON THE KEYBOARD\nWHEN THE ADJECTIVE IS <color=00ff00>POSITIVE<color> (e.g. ''good'').\n\n'...
    '--> PRESS ''<color=ff0000>M<color>'' ON THE KEYBOARD\nWHEN THE ADJECTIVE IS <color=ff0000>NEGATIVE<color> (e.g. ''bad''). '];
    
    % define response keys
    responseKeys = {'x', 'm', 'ESCAPE'};
else
    instructions = ['--> PRESS ''<color=00ff00>M<color>'' ON THE KEYBOARD\nWHEN THE ADJECTIVE IS <color=00ff00>POSITIVE<color> (e.g. ''good'').\n\n'...
    '--> PRESS ''<color=ff0000>X<color>'' ON THE KEYBOARD\nWHEN THE ADJECTIVE IS <color=ff0000>NEGATIVE<color> (e.g. ''bad''). '];

    % define response keys
    responseKeys = {'m', 'x', 'ESCAPE'};
end

% Estimate duration
estDuration = round([nBlocks * nTrials * (fixDur + greenDur + primeDur + respDur + maskDur + iti) / 60],0);

%% Key Mapping Setup, ListenChar, HideCursor
% provide a consistent mapping of keyCodes to key names on all operating systems.
KbName('UnifyKeyNames');

% disable typing to matlab during experiment
ListenChar(2); 

% hide mouse cursor
HideCursor; 

% Instructions text
Screen('TextFont', windowPtr, 'Helvetica');
Screen('TextSize', windowPtr, 30);
insText = sprintf(['Hello %s! Welcome to this experiment about visual perception.\n\n'...
'Once the experiment begins, you will see a fixation dot in the middle of '...
'the screen. Please focus on this dot until it disappears. Just before it '...
'disappears it will turn green. You will see a face and then an adjective. \n\n\n %s \n\n\n Please '...
'respond to the adjective as quickly as possible. \nThis experiment consists of %d blocks and will take about %d minutes.\n\n'...
'Press any key when you are ready to continue.'], answer{2}, instructions, nBlocks, estDuration);

% Text for end of experiment       
finText = 'You have completed the experiment. Thank you for your participation!';

% Text for late response
lateText = 'Please respond sooner!';

%% Make the textures
images = {};
images{1,1} = Screen('MakeTexture', windowPtr, angry_man); % angry man
images{2,1} = Screen('MakeTexture', windowPtr, angry_woman); % angry woman
images{1,2} = Screen('MakeTexture', windowPtr, happy_man); % happy man
images{2,2} = Screen('MakeTexture', windowPtr, happy_woman); % happy woman

scrambled_images{1,1} = Screen('MakeTexture', windowPtr,scrambled_angry_man); % angry man
scrambled_images{2,1} = Screen('MakeTexture', windowPtr,scrambled_angry_woman); % angry woman
scrambled_images{1,2} = Screen('MakeTexture', windowPtr,scrambled_happy_man); % happy man
scrambled_images{2,2} = Screen('MakeTexture', windowPtr,scrambled_happy_woman); % happy woman

%% Preallocate variables that will change/append in every loop 
% preallocate condition variables
trialPrime      = zeros(nTrials,nBlocks);
trialValence    = zeros(nTrials,nBlocks);
trialTarget     = cell(nTrials,nBlocks); % empty cell array

% preallocate result variables
RT              = zeros(nTrials,nBlocks); % reaction times 
Correct         = zeros(nTrials,nBlocks); % correct = 1, incorrect = 0, no response = 2

% preallocate timing measurements
trialPrimeDur   = zeros(nTrials,nBlocks);
trialTargetDur  = zeros(nTrials,nBlocks);
startTime       = zeros(nTrials,nBlocks);

%% Start Experiment

%% Experimental Loop (Blocks)
for b = 1:nBlocks

    % display instructions before 1st block
    if b == 1
%         DrawFormattedText(windowPtr, insText, 'center', 'center', 0, 77);
        DrawFormattedText2(insText, 'win', windowPtr, 'sx', 'center', 'sy', 'center', 'xalign', 'center', 'yalign', 'center', 'baseColor',000000, 'wrapat', 80);
        Screen('Flip', windowPtr);
        WaitSecs(1);
        KbWait;
    end

    % display which block we are on
    blockText = ['Block ', num2str(b), ' out of ', num2str(nBlocks),...
                 ' !\n\n\nPress any key to start block!'];
    DrawFormattedText(windowPtr, blockText, 'center', 'center', 0, 77);
    Screen('Flip', windowPtr);
    WaitSecs(0.3);
    KbWait;

    %% Trial Loop
    for t = 1:nTrials
        % Experimental setup
        vbl = Screen('Flip', windowPtr); % initial flip
        Screen('TextSize', windowPtr, 56); % font size of target adjective
        trialPrime(t,b)     = TrialMat(2,t);                        % select each condition from the trial matrix
        trialValence(t,b)   = TrialMat(3,t);                        % adjective valence type (or just do it randomly)
        valence             = trialValence(t,b);                    % selecting target valence
        trialTarget(t,b)    = datasample(adjectives(:,valence), 1); % selecting target adjective randomly with the appropriate valence
        target              = char(trialTarget{t,b});               % convert into a string        
        
        % FIXATION POINT
        Screen('FillOval', windowPtr, black, fixRect);      % Draw fixation point 
        fixOn = Screen('Flip', windowPtr, vbl + iti);       % flip to screen
        
        Screen('FillOval', windowPtr, [0 255 0], fixRect);  % Draw green fixation point
        greenOn = Screen('Flip', windowPtr, fixOn + fixDur); 
        
        if trialPrime(t,b) == 1             % select prime and according mask
            f = 1;                          % angry man
        elseif trialPrime(t,b) == 2
            f = 2;                          % angry woman
        elseif trialPrime(t,b)  == 3
            f = 3;                          % happy man
        else
            f = 4;                          % happy woman
        end
        prime = images{f};
        mask = scrambled_images{f};
        
        % PRIME
        Screen('DrawTexture', windowPtr, prime, [], targetRect_Center); % draw prime in buffer
        primeOn = Screen('Flip', windowPtr, greenOn + greenDur);  % flip to screen after end of fixation point duration
        
        % MASK
        Screen('DrawTexture', windowPtr, mask, [], targetRect_Center); % draw mask in buffer
        maskOn = Screen('Flip', windowPtr, primeOn + primeDur); % flip to screen after end of prime    
        
        % TARGET      
        keyIsDown = 0;  % reseting to 0 in each new trial
        response = 0;   % set this to 0 so that the variable response is known
                
        DrawFormattedText(windowPtr, target, 'center', 'center', black); % choose random adjective from the previously selected valence
        targetOn = Screen('Flip', windowPtr, maskOn + maskDur); % flip to screen after end of 2nd mask
        
        for u = 1:(tDur-1) % Loop for the duration of target display
            % abort when a key is pressed
            [keyIsDown, pressedSecs, keyCode] = KbCheck();
            
            DrawFormattedText(windowPtr, target, 'center', 'center', black); % choose random adjective from the previously selected valence
            targetOff = Screen('Flip', windowPtr); % flip to screen 
            
            if keyIsDown
                response = KbName(find(keyCode));
                
                if strcmp(response,responseKeys{3}) % if ESC is pressed, exit!
                    sca;
                    clear Screen;
                    ListenChar();                % reenable keyboard input to matlab
                    ShowCursor;
                    disp('Error: ESCAPE break'); % display this text
                    return;                      % exit
                end
                
                RT(t,b) = pressedSecs - targetOn;

                if ismember(response, responseKeys)
                    if strcmp(response,responseKeys{valence}) % when a correct response is given
                        Correct(t,b) = 1;
                    else
                        Correct(t,b) = 0;
                    end 
                    break;
                end 
            end
        end
        
        % CLEAR SCREEN
        while ~keyIsDown && (GetSecs - targetOn) < respDur % execute only if no key has been pressed previously. 
                                                           % continue until a key is pressed or response time has elapsed
            % abort when a key is pressed
            [keyIsDown, pressedSecs, keyCode] = KbCheck();
            Screen('Flip', windowPtr); % clear screen after targetDur
            
            if keyIsDown
                response = KbName(find(keyCode));
                
                if strcmp(response,responseKeys{3}) % if ESC is pressed, exit!
                    sca;
                    clear Screen;
                    ListenChar();                % reenable keyboard input to matlab
                    ShowCursor;
                    disp('Error: ESCAPE break'); % display this text
                    return;                      % exit
                end
                
                RT(t,b) = pressedSecs - targetOn;
                
                if ismember(response, responseKeys)
                    if strcmp(response,responseKeys{valence}) % when a correct response is given
                        Correct(t,b) = 1;
                    else
                        Correct(t,b) = 0;
                    end 
                    break;
                end
            end
        end

        if ~keyIsDown
            Screen('TextSize', windowPtr, 30);
            DrawFormattedText(windowPtr, lateText, 'center', 'center', black);
            Screen('Flip', windowPtr);
            WaitSecs(1.0);
            Correct(t,b) = 2; % no response was given in time
        end
        
       %% SAVING TIMES
        trialPrimeDur(t,b)      = maskOn - primeOn;     % saving timing info of stimuli in each trial
        trialTargetDur(t,b)     = targetOff - targetOn;
    end
end

%% ADJECTIVES RATING TASK
% Rates the adjectives that were used in the specific experiment according
% to their valence on a scale from 1 (neg) to 7 (pos) 
WaitSecs(1);
Screen('TextSize', windowPtr, 30);
DrawFormattedText(windowPtr, ['You are almost finished with the experiment. \n\n'...
    'Please rate the following adjectives on a scale from 1 (very negative) to 7 (very positive) \n'...
    'according to how positive/negative you think they are. \n\n Use the number keys (1 - 7) to rate.'...
    '\n\nPress any key when you are ready to continue.'], 'center', 'center', black);
Screen('Flip', windowPtr);
WaitSecs(1);
KbWait;

ratingVector        = reshape(trialTarget',[],1); 
ratingArray         = unique(cellstr(ratingVector));
ratingKeys          = {'1','2','3','4','5','6','7','1!','2@','3#','4$','5%','6^','7&'};

Screen('TextSize', windowPtr, 56);

for x = 1:length(ratingArray)
    keyIsDown = 0;
    rating = 0;
    ratingText = sprintf(('%s \n\n\n\n\n (very negative) 1 <--        --> 7 (very positive)'), ratingArray{x,1});
    while true
        [keyIsDown, pressedSecs, keyCode] = KbCheck();
        DrawFormattedText(windowPtr, ratingText, 'center', 'center', black);
        Screen('Flip', windowPtr);
        
        if keyIsDown
            rating = KbName(find(keyCode));
            
            if strcmp(rating,responseKeys{3}) % if ESC is pressed, exit!
                sca;
                clear Screen;
                ListenChar();                % reenable keyboard input to matlab
                ShowCursor;
                disp('Error: ESCAPE break'); % display this text
                return;                      % exit
            end
            
            if ismember(rating,ratingKeys)
                ratingArray{x,2} = str2num(rating(1)); % just the first character of the key name (e.g. 7 of '7&') as an integer
                WaitSecs(0.2);
                break;
            end
        end        
    end
end

%% Save data
save(['Subject_' num2str(subNum) '.mat']); % this saves all the variables in the workspace
                                           % to a file called
                                           % Subject_XX.mat
                                           
%% Final Screen
Screen('TextSize', windowPtr, 30);
DrawFormattedText(windowPtr, finText, 'center', 'center', black);
Screen('Flip', windowPtr);
KbWait();

%% Closing screen
sca;
clear Screen;
ShowCursor();
ListenChar();