% FGET_SPK               Retrieve spike times from file
% 
%     [events,hdr] = fget_spk(input,option);
%
%     INPUTS
%     input   - filename (string) for binary file containing spike times
%
%     OPTIONAL
%     option  - determines whether to return or skip spike file header,
%               default = 'skip'
%  
%     OUTPUTS
%     events  - vector of spike times
%     hdr     - structure containing spike file header
%
%     brian 03.22.99
%
%     $ Revision 1.0 - brian 08.16.99 - added repeat ability for backward $
%     $                                 compatibility w/ DATAWAVE data    $
%     $ Revision 1.1 - brian 09.16.99 - updated to newnew data format     $

function [events,hdr] = fget_spk(input,option);

%----- Globals & constants
global VERBOSE;               
SPKHDRSIZE = 828;             % Header size in bytes
DTYPE = 'int32';              % Default data type

%----- Check arguments
if nargin == 0 | nargin > 2
   error('Wrong number of inputs to FGET_SPK!');
elseif nargin < 2
   option = 'skip';
end

%----- Datawave compatability
if findstr(input,'mq')
   DTYPE = 'uint32';
elseif findstr(input,'film02')
   DTYPE = 'uint32';
elseif findstr(input,'film32')
   DTYPE = 'uint32';
else
   DTYPE = 'int32';
end

if findstr(input,'cell')
   %----- Shanghai Data
   input = [input ' spiketiming.txt'];
   events = dlmread(input,',',1,0);
   count = length(events);
else
   %----- Open file & read in first 16 bytes
   warning off;
   [fid,message] = fopen(input,'rb','ieee-le');
   if fid < 0; fprintf('\n%s\n',message); end
   hdrchk = char(fread(fid,16,'int8'))';
   
   %-- determine if there is header or just spike times
   if findstr(hdrchk,'DAN_SPK')
      if strcmp(option,'skip')
         fseek(fid,SPKHDRSIZE,'bof');
         [events,count] = fread(fid,inf,DTYPE);
      else
         hdr = fget_hdr(fid);
         fseek(fid,SPKHDRSIZE,'bof');
         [events,count] = fread(fid,inf,DTYPE);
      end
   else
      frewind(fid);
      [events,count] = fread(fid,inf,DTYPE);
   end

   fclose(fid);
   warning on;
end

if VERBOSE; fprintf('  Spike Count:  %i\n',count); end

return
