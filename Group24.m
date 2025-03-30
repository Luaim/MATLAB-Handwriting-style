%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                Luai - TP070855                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Group24()
% GROUP24
%   This is the MATLAB GUI for handwriting analysis with six unique features:
%   * Cursive (3 features):
%       (1) Pen-Lift Frequency
%       (2) Intersection Density
%       (3) Proportion of Merged Letters
%   * Print (3 features):
%       (1) Character Rectangularity
%       (2) Width Variance
%       (3) Avg. Black-White Transitions (Horizontal)

    %% 1. Create the Main Figure
    f = figure('Name','Handwriting Feature Extraction GUI',...
               'Units','normalized',...
               'Position',[0.2,0.2,0.6,0.6]);

    %% 2. Create Axes for Original and Processed Images
    axOriginal = axes('Parent',f,...
                      'Units','normalized',...
                      'Position',[0.05,0.3,0.4,0.65]);
    title(axOriginal,'Original Image');

    axProcessed = axes('Parent',f,...
                       'Units','normalized',...
                       'Position',[0.55,0.3,0.4,0.65]);
    title(axProcessed,'Processed Image');

    %% 3. Create a Drop-Down Menu to Select "Cursive" or "Print"
    styleMenu = uicontrol('Parent',f,...
                          'Style','popupmenu',...
                          'String',{'Select Style','Cursive','Print'},...
                          'Units','normalized',...
                          'Position',[0.05,0.2,0.2,0.05],...
                          'Value',1);  % <-- Corrected syntax

    %% 4. Create a "Pick Image" Button
    btnPickImage = uicontrol('Parent',f,...
                             'Style','pushbutton',...
                             'String','Pick Image',...
                             'Units','normalized',...
                             'Position',[0.3,0.2,0.2,0.05],...
                             'Callback',@pickImageCallback);

    %% 5. Create an "Extract Features" Button
    btnExtract = uicontrol('Parent',f,...
                           'Style','pushbutton',...
                           'String','Extract Features',...
                           'Units','normalized',...
                           'Position',[0.55,0.2,0.2,0.05],...
                           'Callback',@extractFeaturesCallback);

    %% 6. Create a Textbox to Display Output
    txtOutput = uicontrol('Parent',f,...
                          'Style','edit',...
                          'Units','normalized',...
                          'Position',[0.05,0.05,0.9,0.1],...
                          'Max',2,... % allows multi-line text
                          'HorizontalAlignment','left');

    %% 7. Store GUI Data in a Struct (handles)
    handles.axOriginal  = axOriginal;
    handles.axProcessed = axProcessed;
    handles.txtOutput   = txtOutput;
    handles.styleMenu   = styleMenu;
    handles.img         = [];
    guidata(f, handles);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%                Nested Callback Functions Definition               %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function pickImageCallback(src, ~)
        % Opens a file dialog to pick a handwriting image
        [filename, pathname] = uigetfile({'*.png;*.jpg;*.jpeg','Image Files'},...
                                         'Select a Handwriting Image');
        if isequal(filename,0)
            % User canceled
            return;
        end

        % Construct the full path and read the image
        fullpath = fullfile(pathname, filename);
        img = imread(fullpath);

        % Retrieve the handles struct and store the chosen image
        handles = guidata(src);
        handles.img = img;  
        guidata(src, handles);

        % Display in the Original Image axis
        imshow(img, 'Parent', handles.axOriginal);
        title(handles.axOriginal, 'Original Image');

        % Clear the Processed Image axis and text output
        cla(handles.axProcessed);
        set(handles.txtOutput, 'String', '');
    end

    function extractFeaturesCallback(src, ~)
        % Extracts features based on the chosen style (Cursive or Print)
        handles = guidata(src);

        % 1. Ensure an image is picked
        if isempty(handles.img)
            warndlg('Please pick an image first!');
            return;
        end

        % 2. Check the style from the drop-down menu
        menuIdx = get(handles.styleMenu,'Value');
        menuItems = get(handles.styleMenu,'String');
        chosenStyle = menuItems{menuIdx};

        if strcmp(chosenStyle, 'Select Style')
            warndlg('Please select either "Cursive" or "Print" first.');
            return;
        end

        % 3. Convert to grayscale if needed, then binarize
        img = handles.img;
        if size(img,3) == 3
            grayImg = rgb2gray(img);
        else
            grayImg = img;
        end
        bwImg = imbinarize(grayImg);

        % 4. Optional morphological cleanup
        bwImg = bwmorph(bwImg,'open');

        % 5. Display the processed (binary) image
        imshow(bwImg, 'Parent', handles.axProcessed);
        title(handles.axProcessed, 'Processed Image');

        % 6. Extract the features based on style
        if strcmp(chosenStyle,'Cursive')
            [penLift, intersectDens, mergedProp] = extractCursiveFeatures(bwImg);
            outStr = sprintf([ ...
                'Cursive Features:\n',...
                '1) Pen-Lift Frequency: %.2f\n',...
                '2) Intersection Density: %.4f\n',...
                '3) Proportion of Merged Letters: %.2f\n'], ...
                penLift, intersectDens, mergedProp);
        else
            % chosenStyle == 'Print'
            [rectang, widthVar, avgTransitions] = extractPrintFeatures(bwImg);
            outStr = sprintf([ ...
                'Print Features:\n',...
                '1) Character Rectangularity: %.4f\n',...
                '2) Width Variance: %.4f\n',...
                '3) Avg. Black-White Transitions: %.2f\n'], ...
                rectang, widthVar, avgTransitions);
        end

        % 7. Display the results in the textbox
        set(handles.txtOutput, 'String', outStr);
    end

end % End of main function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%              Feature Extraction for Cursive (3 Features)              %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [penLiftFreq, intersectionDensity, mergedProp] = extractCursiveFeatures(bwImg)
% EXTRACTCURSIVEFEATURES
%  Computes three distinct features for cursive handwriting:
%   1) Pen-Lift Frequency
%   2) Intersection Density
%   3) Proportion of Merged Letters

    % 1) Pen-Lift Frequency
    skelImg = bwmorph(bwImg,'skel',Inf);
    ccSkel = bwconncomp(skelImg);
    penLiftFreq = ccSkel.NumObjects;

    % 2) Intersection Density
    branchPoints = bwmorph(skelImg,'branchpoints');
    nBranch = sum(branchPoints(:));
    skelLength = sum(skelImg(:));
    if skelLength == 0
        intersectionDensity = 0;
    else
        intersectionDensity = nBranch / skelLength;
    end

    % 3) Proportion of Merged Letters
    ccText = bwconncomp(bwImg);
    props = regionprops(ccText,'BoundingBox','Area');

    areaVals = [props.Area];
    % If your cursive letters are small or large, adjust these thresholds:
    minArea = 30;
    maxArea = 5000;
    validIdx = find(areaVals > minArea & areaVals < maxArea);
    validCount = numel(validIdx);
    if validCount == 0
        mergedProp = 0;
        return;
    end

    validProps = props(validIdx);
    mergedCount = 0;
    for i = 1:validCount
        bb = validProps(i).BoundingBox;  % [x, y, width, height]
        w = bb(3);
        % We'll call it "merged" if the letter is wider than 50 px
        % Adjust as needed if your cursive letters are narrower/wider
        if w > 50
            mergedCount = mergedCount + 1;
        end
    end
    mergedProp = mergedCount / validCount;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%               Feature Extraction for Print (3 Features)               %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [avgRectangularity, widthVariance, meanTransitions] = extractPrintFeatures(bwImg)
% EXTRACTPRINTFEATURES
%   Computes three distinct features for print handwriting:
%     1) Character Rectangularity
%     2) Width Variance
%     3) Avg. Black-White Transitions (Horizontal)

    cc = bwconncomp(bwImg);
    props = regionprops(cc,'BoundingBox','Area');

    % Filter out noise/very large components
    areaVals = [props.Area];
    % Adjust thresholds if you see all zeros for print
    minArea = 25;
    maxArea = 6000;
    validIdx = find(areaVals > minArea & areaVals < maxArea);
    if isempty(validIdx)
        % No valid letters => zero out everything
        avgRectangularity = 0;
        widthVariance     = 0;
        meanTransitions   = 0;
        return;
    end

    validProps = props(validIdx);
    bboxes = vertcat(validProps.BoundingBox); % Nx4: [x, y, width, height]
    areas  = [validProps.Area];

    % 1) Character Rectangularity
    widths  = bboxes(:,3);
    heights = bboxes(:,4);
    rectVals = areas ./ (widths .* heights);
    avgRectangularity = mean(rectVals);

    % 2) Width Variance
    widthVariance = var(widths);

    % 3) Avg. Black-White Transitions (Horizontal)
    [rows, ~] = size(bwImg);
    transitionsPerRow = zeros(rows,1);
    for r = 1:rows
        rowData = bwImg(r,:);
        % Count how many times the row transitions from 0->1 or 1->0
        transitions = sum(rowData(1:end-1) ~= rowData(2:end));
        transitionsPerRow(r) = transitions;
    end
    meanTransitions = mean(transitionsPerRow);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                Abdul Basith - TP071822                           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                Abdulelah  - TP067554                             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

