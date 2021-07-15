% neuroscience project
% implemented paper : Isolation of Relevant Visual Features from Random Stimuli for
% Cortical Complex Cells, 
% Authors: Jon Touryan,1 Brian Lau,2 and Yang Dan1,2

close all; clc; clear;
addpath('MatlabFunctions\fileload');
addpath('MatlabFunctions\tview');
addpath('Data\Spike_and_Log_Files');
% part.1 - Dataset
% sa0 files
numberOfFrames = 32767;
T = 1/59.721395; % s

% all neurons name vector
nameVector = ["000412.a01","000413.b03","000413.b04","000413.b05",...
    "000418.a01","000419.a06","000419.a07","000419.a09","000420.b02",...
    "000503.a03","000511.b09","000511.b10","000513.d11","000524.c01","000525.d05",...
    "000601.c05","000601.c07","000620.a02","000622.f03","000622.f04",...
    "000622.f05","000712.b03","000712.b04","000720.c06","000802.c05",...
    "000802.c06","000802.c07","000804.i01","000823.d04","000824.g04",...
    "000907.f07","000914.c06","000914.c07","000926.a04","010125.A.c02",...
    "010125.A.c03","010208.A.h01","010322.A.f06","010524.A.f01","010613.B.b02",...
    "010614.B.e08","010628.A.c03","010628.A.c04","010718.B.c01","010718.B.c02",...
    "010801.A.b01","011019.A.c09","011024.A.b04","011025.A.d07","011101.A.d02",...
    "011101.A.d03","011121.A.d02","020109.A.b01","020109.A.b02","020213.A.i01",...
    "020214.A.j01","020306.A.a01","020306.A.a02","020308.A.d01","020321.A.i01",...
    "020321.A.i02"];

% 2.2 - specified neuron - hdr and events - msq1D - sa0
neuronCode = nameVector(1); % change the index for other neurons
msq1Dstruct = Func_ReadData(neuronCode)

% 2.3 - spike count rate - histogram
SCR = [];
for i=1:length(nameVector)
    SCR = [SCR plotSpikeCountRate(nameVector(i),Func_ReadData(nameVector(i)),T,numberOfFrames)];
end
figure;
X = categorical(nameVector);
bar(X,SCR.','FaceColor','#A2142F','EdgeColor','#A2142F');
title('spike count rate histogram','interpreter','latex');

% neurons with SCR less than 2
lessThanTwoSCRsNeuronCodes = (nameVector(find(SCR<2))).'
hold on;
line([X(1) X(61)],[2 2],'Color','blue','LineStyle','--','LineWidth',2); % border
hold off;

% 2.4 - load msq1D stimulus
msq1D = load('Data\Stimulus_Files\msq1D.mat').msq1D;
neuronCode = nameVector(1);
experimentID = "a01emsq1D";
msq1Dprime = vertcat(msq1D,zeros(1,16));
[targetExperiment stimuliExtracted] = Func_StimuliExtraction(neuronCode,experimentID,msq1Dprime,T,0,0);

% 2.5 - tview
% change the input of the tview and the address of the neuron directory for
% other tview outputrs
cd C:\Users\Utel\Desktop\Neuroscience_Project\Data\Spike_and_Log_Files\000412.a01 % change this address depend on your computer 
tview('000412.a01atune.log');
cd C:\Users\Utel\Desktop\Neuroscience_Project\

% 3.1. STA
figure;
spikeTriggeredAveraged = mean(stimuliExtracted,3);

subplot(1,2,1);
imshow(mat2gray(spikeTriggeredAveraged));
title('STA - 000412.a01emsq1D','interpreter','latex');
xlabel('Spatial');
ylabel('Temporal');

% 3.2. P-Value
pTest = zeros(16,16);
for i = 1:16
    for j = 1:16
        [h,pTest(i,j)] = ttest2(stimuliExtracted(i,j,:),0);
    end
end
subplot(1,2,2);
imshow(mat2gray(pTest));
title('P Value - 000412.a01emsq1D','interpreter','latex');
xlabel('Spatial');
ylabel('Temporal');

% 3.3. histogram
normalStimulus = reshape(msq1Dprime,16,16,(numberOfFrames+1)/16);
spikeTriggeredAveragedSize = sqrt(sum(spikeTriggeredAveraged.*spikeTriggeredAveraged,'all')); 
for i = 1:(numberOfFrames+1)/(16)
    allStimulusImage(i) = sum(normalStimulus(:,:,i).*spikeTriggeredAveraged,'all');
end

for i = 1:size(stimuliExtracted,3)
    spikeTriggeredImage(i) = sum(stimuliExtracted(:,:,i).*spikeTriggeredAveraged,'all');
end
nbins = 15;
figure;
h1 = histogram(spikeTriggeredImage/spikeTriggeredAveragedSize,nbins,'Normalization','probability')
hold on
h2 = histogram(allStimulusImage/spikeTriggeredAveragedSize,nbins,'Normalization','probability')
legend('Control','Spike');
hold off

% 3.4. p-value

pTest2 = zeros(16,16);
for i = 1:16
    for j = 1:16
        [h2,pTest2(i,j)] = ttest2(stimuliExtracted(i,j,:),normalStimulus(i,j,:));
    end
end
figure;
imshow(mat2gray(pTest2));
title('P Value - Spike triggered averages and All spikes','interpreter','latex');
xlabel('Spatial');
ylabel('Temporal');


% 4.1. correlation matrix
correlationMatrix = correlationMatrixCalculator(stimuliExtracted);
[eigVectors,eigValues] = eig(correlationMatrix);
eigValues = diag(eigValues);
v1 = reshape(eigVectors(:,end),16,16);
v2 = reshape(eigVectors(:,end-1),16,16);
v3 = reshape(eigVectors(:,end-2),16,16);
figure;
%biggest
subplot(1,3,1);
imshow(mat2gray(v1));
title('V1 - 000412.a01emsq1D','interpreter','latex');
%second biggest
subplot(1,3,2);
imshow(mat2gray(v2));
title('V2 - 000412.a01emsq1D','interpreter','latex');
%third biggest
subplot(1,3,3);
imshow(mat2gray(v3));
title('V3 - 000412.a01emsq1D','interpreter','latex');


% 4.2. confidence intervals
% create 5 random times spikes vector
controlVec1 = (sort(randperm(floor(numberOfFrames*T*10^4),length(msq1Dstruct(targetExperiment).events)))).';
controlVec2 = (sort(randperm(floor(numberOfFrames*T*10^4),length(msq1Dstruct(targetExperiment).events)))).';
controlVec3 = (sort(randperm(floor(numberOfFrames*T*10^4),length(msq1Dstruct(targetExperiment).events)))).';
controlVec4 = (sort(randperm(floor(numberOfFrames*T*10^4),length(msq1Dstruct(targetExperiment).events)))).';
controlVec5 = (sort(randperm(floor(numberOfFrames*T*10^4),length(msq1Dstruct(targetExperiment).events)))).';

% simuli extraction
[targetExperiment stimuliControlExtracted1] = Func_StimuliExtraction(neuronCode,experimentID,msq1Dprime,T,1,controlVec1);
[targetExperiment stimuliControlExtracted2] = Func_StimuliExtraction(neuronCode,experimentID,msq1Dprime,T,1,controlVec2);
[targetExperiment stimuliControlExtracted3] = Func_StimuliExtraction(neuronCode,experimentID,msq1Dprime,T,1,controlVec3);
[targetExperiment stimuliControlExtracted4] = Func_StimuliExtraction(neuronCode,experimentID,msq1Dprime,T,1,controlVec4);
[targetExperiment stimuliControlExtracted5] = Func_StimuliExtraction(neuronCode,experimentID,msq1Dprime,T,1,controlVec5);

% correlation control matrices
correlationControlMat1 = correlationMatrixCalculator(stimuliControlExtracted1);
correlationControlMat2 = correlationMatrixCalculator(stimuliControlExtracted2);
correlationControlMat3 = correlationMatrixCalculator(stimuliControlExtracted3);
correlationControlMat4 = correlationMatrixCalculator(stimuliControlExtracted4);
correlationControlMat5 = correlationMatrixCalculator(stimuliControlExtracted5);

% eig values/vectors of control correlation matrices
[eigControlVectors1,eigControlValues1] = eig(correlationControlMat1);
eigControlValues1 = diag(eigControlValues1); 
[eigControlVectors2,eigControlValues2] = eig(correlationControlMat2);
eigControlValues2 = diag(eigControlValues2); 
[eigControlVectors3,eigControlValues3] = eig(correlationControlMat3);
eigControlValues3 = diag(eigControlValues3); 
[eigControlVectors4,eigControlValues4] = eig(correlationControlMat4);
eigControlValues4 = diag(eigControlValues4); 
[eigControlVectors5,eigControlValues5] = eig(correlationControlMat5);
eigControlValues5 = diag(eigControlValues5); 

meanEigControlValues = (eigControlValues1+eigControlValues2+eigControlValues3+...
    eigControlValues4+eigControlValues5)./5;

% control confidence interval
SD = std(meanEigControlValues);
z = 10.4; % change z if you changed the neuron and expirement for better results
upperBorder = meanEigControlValues(end:-1:end-29) + z*SD/sqrt(256);
lowerBorder = meanEigControlValues(end:-1:end-29) - z*SD/sqrt(256);

% 30 most principle eigen values
figure;
plot(1:30,eigValues(end:-1:end-29),'.');
% borders
hold on;
plot(1:30,upperBorder);
plot(1:30,lowerBorder);
xlabel('Rank');
ylabel('EigenValues');
legend('eigenValues','upperBorder','LowerBorder');
hold off;

% 4.4. histogram
v1 = reshape(eigVectors(end,:),256,1);
v2 = reshape(eigVectors(end-1,:),256,1);

stimuliExtracted = reshape(stimuliExtracted,[],256);
spikeTriggeredImageOnEigenVector1 = (stimuliExtracted)*v1;
spikeTriggeredImageOnEigenVector2 = (stimuliExtracted)*v2;
normalStimulus = reshape(normalStimulus,[],256);
allStimulusImageOnEigenVector1 = normalStimulus*v1;
allStimulusImageOnEigenVector2 = normalStimulus*v2;

figure;
histogram2(spikeTriggeredImageOnEigenVector1,spikeTriggeredImageOnEigenVector2,'Normalization','probability')
hold on
histogram2(allStimulusImageOnEigenVector1,allStimulusImageOnEigenVector2,'Normalization','probability')
title('000412.a01emsq1D','interpreter','latex');
xlabel('V1');
ylabel('V2');
legend('Spike','Control');
hold off

%% functions
function outputStruct = Func_ReadData(neuronCode)
    % output directory
    cd C:\Users\Utel\Desktop\Neuroscience_Project % change it to your pc address
    cd Data\Spike_and_Log_Files
    targetFiles = dir('*\'+neuronCode+'*msq1*.sa0');
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

function [targetExperiment stimuliExtraction] = Func_StimuliExtraction(neuronCode,experimentID,msq1D,T,key,controlVec)
    timeSpan = 10000*16*T;
    msq1Dstruct = Func_ReadData(neuronCode);
    targetExperiment = 0;
    for i = 1:length(msq1Dstruct)
    	if(msq1Dstruct(i).hdr.DataInfo.ID == experimentID)
            targetExperiment = i;
            break;
        end
    end
    if(key == 0)
        triggered_stimulus = ceil(msq1Dstruct(targetExperiment).events/timeSpan);
    else
        triggered_stimulus = ceil(controlVec/timeSpan);
    end
    stimuliExtraction = zeros(16,16,length(triggered_stimulus));
    for i=1:length(triggered_stimulus)
        stimuliExtraction(:,:,i) = msq1D(((triggered_stimulus(i)-1)*16+1):((triggered_stimulus(i))*16),:);
    end
end

function correlationMat = correlationMatrixCalculator(inputSignal)
    correlationMat = zeros(256,256);
    inputSignalvert = reshape(inputSignal,256,1,[]);
    inputSignalhor = reshape(inputSignal,1,256,[]);
    for i = 1:size(inputSignal,3)
        correlationMat = correlationMat + inputSignalvert(:,:,i)*inputSignalhor(:,:,i);
    end
    correlationMat = correlationMat./size(inputSignal,3);    
end


