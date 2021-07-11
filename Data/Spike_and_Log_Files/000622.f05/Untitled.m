addpath('d:\03 - Neuroscience Course\My Files\HW\HW01\Data\CRCNS_ORG_PVC_2\crcns-pvc2-matlab-files\fileload\')
addpath('d:\03 - Neuroscience Course\My Files\HW\HW01\Data\CRCNS_ORG_PVC_2\crcns-pvc2-matlab-files\tview\')
addpath('d:\03 - Neuroscience Course\My Files\HW\HW01\Data\CRCNS_ORG_PVC_2\crcns-pvc2\1D_white_noise\Stimulus_Files\')

[events,hdr] = fget_spk('000622.f05atune.sa0','yes');
max(events)/hdr.DataInfo.SampleRate

flog = tview('000622.f05atune.log');

%{
x = 1:max(events);
y = zeros(size(x));
y(events)=1;

stem(x,y)
%}