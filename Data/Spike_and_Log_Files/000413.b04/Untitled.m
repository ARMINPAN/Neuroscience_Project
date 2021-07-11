clc
clear
close all
%% Add Path
% functions to load spkie times:
addpath('d:\03 - Neuroscience Course\My Files\HW\HW01\Data\CRCNS_ORG_PVC_2\crcns-pvc2-matlab-files\fileload\')
% functions to view tuning curve:
addpath('d:\03 - Neuroscience Course\My Files\HW\HW01\Data\CRCNS_ORG_PVC_2\crcns-pvc2-matlab-files\tview\')
% stimuli:
addpath('d:\03 - Neuroscience Course\My Files\HW\HW01\Data\CRCNS_ORG_PVC_2\crcns-pvc2\1D_white_noise\Stimulus_Files\')
%% Load Files:
[events,hdr] = fget_spk('000413.b04emsq1D.sa0','yes');
disp()
max(events)/hdr.DataInfo.SampleRate

load('msq1D.mat')
size(msq1D,1)/120

(max(events)/hdr.DataInfo.SampleRate)/(size(msq1D,1)/120)

%{
x = 1:max(events);
y = zeros(size(x));
y(events)=1;

stem(x,y)
%}

%%
temp = zeros(1,size(msq1D,1));
for m = 1:size(msq1D,1)
    A = -repmat(msq1D(m,:),size(msq1D,1),1);
    temp(m) = sum(prod(A==msq1D,2));
end