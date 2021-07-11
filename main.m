% neuroscience project
% implemented paper : Isolation of Relevant Visual Features from Random Stimuli for
% Cortical Complex Cells, 
% Authors: Jon Touryan,1 Brian Lau,2 and Yang Dan1,2
addpath('MatlabFunctions\fileload');
addpath('MatlabFunctions\tview');
close all; clc; clear;
% part.1 - Dataset
% sa0 files
numberOfFrames = 32767;
T = 1/59.721395; % s

% all neurons name vector
nameVector = ["000412", "000413", "000418", "000419", "000420"...
    "000503", "000511", "000513", "000524", "000525", "000601"...
"000620", "000622", "000712", "000720", "000802", "000804"...
"000823", "000824", "000907", "000914", "000926", "010125.A"...
"010208.A", "010322.A", "010524.A", "010612.B", "010614.B"...
"010628.A", "010718.B", "010801.A", "011019.A", "011024.A"...
"011025.A", "011101.A", "011121.A", "020109.A", "020213.A"...
"020214.A", "020306.A", "020308.A", "020321.A"];

% specified neuron - hdr and events - msq1D - sa0
neuronCode = nameVector(2); % change the index for other neurons
msq1Dstruct = Func_ReadData(neuronCode)

% spike count rate - histogram
SCR = [];
for i=1:length(nameVector)
    SCR = [SCR plotSpikeCountRate(nameVector(i),Func_ReadData(nameVector(i)),T,numberOfFrames)];
end
figure;
X = categorical(nameVector);
bar(X,SCR.','FaceColor','#A2142F','EdgeColor','#A2142F');
title('spike count rate histogram','interpreter','latex');

% neurons with SCR less than 2
lessThanTwoSCRsNeuronCodes = nameVector(find(SCR<2))

% load msq1D stimulus
msq1D = load('Data\Stimulus_Files\msq1D.mat').msq1D;
neuronCode = "000413";
experimentID = "b03bmsq1D";
stimuliExtracted = Func_StimuliExtraction(neuronCode,experimentID,msq1D,T);


%% functions
function outputStruct = Func_ReadData(neuronCode)
    % output directory
    cd C:\Users\Utel\Desktop\Neuroscience_Project
    cd Data\Spike_and_Log_Files
    targetFiles = dir ('*\'+neuronCode+'*msq1*.sa0');
    outputStruct = struct('events',{},'hdr',{});
    for i=1:length(targetFiles)
        input = strcat(targetFiles(i).folder,'\',targetFiles(i).name);
        [events,hdr] = fget_spk(input,'return');
        outputStruct(end+1) = struct('events',events,'hdr',hdr);
    end
    % return to main directory
    cd ..\..
end

function SCR = plotSpikeCountRate(neuronCode,msq1Dstruct,T,numberOfFrames)
    % SCR = spike count rate
    SCR = 0;
    for i=1:length(msq1Dstruct)
        SCR = SCR + (length(msq1Dstruct(i).events));
    end
    SCR = SCR/(length(msq1Dstruct)*T*numberOfFrames);
end

function stimuliExtraction = Func_StimuliExtraction(neuronCode,experimentID,msq1D,T)
    timeSpan = 10000*16*T;
    msq1Dstruct = Func_ReadData(neuronCode);
    targetExperiment = 0;
    for i = 1:length(msq1Dstruct)
    	if(msq1Dstruct(i).hdr.DataInfo.ID == experimentID)
            targetExperiment = i;
            break;
        end
    end
    triggered_stimulus = ceil(msq1Dstruct(targetExperiment).events/timeSpan);
    stimuliExtraction = zeros(16,16,length(triggered_stimulus));
    for i=1:length(triggered_stimulus)
        stimuliExtraction(:,:,i) = msq1D(((triggered_stimulus(i)-1)*16+1):((triggered_stimulus(i))*16),:);
    end
end







