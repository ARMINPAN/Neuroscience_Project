% FGET_HDR                 Get spike file header
% 
%     [SPKFileHdr] = fget_hdr(fid);
%
%     Reads in the header of the new f21 spk file format.
%
%     INPUTS
%     fid        - file pointer or name of spike file
%
%     OUTPUTS
%     SPKFileHdr - structure with header information
%
%     brian 09.16.99
%

function [SPKFileHdr] = fget_hdr(fid);

%----- Globals & constants
CHAR = 'int8';
INT  = 'int32';

if isstr(fid)
   [fid,message] = fopen(fid,'rb','ieee-le');
   if fid < 0; fprintf('\n%s\n',message); end
else
   frewind(fid);
end

%-- Grab the SPKFileInfo struct
FileInfo.Type = deblank(char(fread(fid,16,CHAR))');       % must be "DAN_SPK"
if ~strcmp(FileInfo.Type,'DAN_SPK')
   error('Bad file type!');
end
FileInfo.Version = deblank(char(fread(fid,16,CHAR))');    % version number
FileInfo.Fname = deblank(char(fread(fid,128,CHAR))');     % file name when CREATED
FileInfo.Creator = deblank(char(fread(fid,128,CHAR))');   % created by
FileInfo.Time = deblank(char(fread(fid,32,CHAR))');       % YMDHMS
%- Skip the extra space
fseek(fid,64,0);                                          % Reserved

%-- Grab the SPKDataInfo struct
DataInfo.ID = deblank(char(fread(fid,128,CHAR))');        % 
DataInfo.DataFrom = deblank(char(fread(fid,128,CHAR))');  % parent raw data file

DataInfo.Channel = fread(fid,1,INT);                      % channel number (0-63)
DataInfo.SampleRate = fread(fid,1,INT);                   % sampling rate
DataInfo.Gain = fread(fid,1,INT);                         % DAQ gain in millivolts
DataInfo.DAQMode = fread(fid,1,INT);                      % 0 = bi-polar
DataInfo.DAQResolution = fread(fid,1,INT);                % 0 = 12 bits, 1 = 16 bits

DataInfo.DataType = fread(fid,1,INT);                     % 0 = int32
DataInfo.DataUnit = fread(fid,1,INT);                     % 0 = 1/10 ms, 1 = 1 ms, 2 = samples
DataInfo.TimeMode = fread(fid,1,INT);                     % 0 = peak, 1 = mid, 2 = valley
DataInfo.TimeOffset = fread(fid,1,INT);                   % 

DataInfo.ThreshPeakHigh = fread(fid,1,INT);               % in DAQReolution / 100
DataInfo.ThreshPeakLow = fread(fid,1,INT);                % in DAQReolution / 100
DataInfo.ThreshValleyHigh = fread(fid,1,INT);             % in DAQReolution / 100
DataInfo.ThreshValleyLow = fread(fid,1,INT);              % in DAQReolution / 100
DataInfo.ThreshWidthMax = fread(fid,1,INT);               % in ms / 100
DataInfo.ThreshWidthMin = fread(fid,1,INT);               % in ms / 100

%- Skip the extra space
fseek(fid,128,0);                                         % Reserved
%ftell(fid)
%-- Put into SPKFileHdr
SPKFileHdr.FileInfo = FileInfo;
SPKFileHdr.DataInfo = DataInfo;

return



