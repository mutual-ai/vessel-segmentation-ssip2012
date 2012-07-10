% rgbImage = imread('.\..\img\gold\glaucoma\glaucoma\01_g.jpg');
% outcome = imread('.\..\img\gold\healthy\healthy_result\01_r.tif');
% outcomeA = imread('.\..\img\gold\healthy\healthy_result\01_ar.tif');
% outcomeH = imread('.\..\img\gold\healthy\healthy_result\01_hr.tif');
% groundTruth = imread('.\..\img\gold\healthy\healthy_manualsegm\01_h.tif');
%% The most commonly-used metrics are sensitivity , specificity and accuracy. 

function [sens spec accu con area leng] = evaluation(groundTruth,outcome)

    groundTruth  = im2bw(groundTruth , 0.5);  % groundTruth =(groundTruth == 255);
    outcome = im2bw(outcome , 0.5);  % outcome =(outcome == 255);

    TP = sum(sum((groundTruth == 1) & (outcome == 1)));
    FP=sum(sum(outcome == 1))-TP;

    TN = sum(sum((groundTruth == 0) & (outcome == 0)));
    FN = sum(sum(outcome == 0))-TN;
    
    P = TP+FN;  % P = sum(sum(groundTruth == 255)); 
    N = FP+TN;  % N = sum(sum(groundTruth == 0));

    %% Sensitivity = the ratio of well-classi?ed vessel.
    sens = TP/P;  % sens = TP/(TP+FN); 

    %% Specificity  = the ratio of well-classi?ed nonvessel (background) pixels.
    spec = TN/N;  % spec = TN/(FP+TN); % spec = 1-FP_rate;

    %% Accuracy = s a measure that provides the ratio of total (both vessel and nonvessel) well-classi?ed pixels
    accu = (TP+TN)/(P+N);


    %% Function for quality assessment of retinal vessel segmentation 
    % based on three functions that evaluate connectivity, area and length in vessel segmentations with respect to 
    % their corresponding reference-standard images.

    [LGT, numGT] = bwlabel(groundTruth, 4); % number of connected components
    [LO, numO] = bwlabel(outcome, 4);

    %% Connectivity = assesses the fragmentation degree between groundTruth and outcome. Since the vascular tree is a connected structure, 
    % proper vascular segmentation is expected to have only a few connected components (ideally one).
    con = 1 -(min(1,(abs(numGT-numO)/P)));


    %% Area = evaluates the degree of overlapping areas between groundTruth and outcome.
    se = strel('disk',3);
    groundTruth_dilate = imdilate(groundTruth,se);
    outcome_dilate = imdilate(outcome,se);

    area = (sum(sum(((outcome_dilate == 1) & (groundTruth == 1)) | ((outcome == 1) & (groundTruth_dilate == 1)))))/(sum(sum((groundTruth == 1)|(outcome == 1))));%

    %% Length = measures the degree of coincidence between groundTruth and outcome in terms of total length
    groundTruth_skeleton = bwmorph(groundTruth,'skel',Inf);
    outcome_skeleton = bwmorph(outcome,'skel',Inf);

    leng = (sum(sum(((outcome_dilate == 1) & (groundTruth_skeleton == 1)) | ((outcome_skeleton == 1) & (groundTruth_dilate == 1)))))/(sum(sum((groundTruth_skeleton == 1)|(outcome_skeleton == 1))));

end