% FLOAD_LOG               Load data from f21 log file
% 
%     lines = fload_log(filename);
%
%     INPUTS
%     filename   - filename (string) of the log file
%  
%     OUTPUTS
%     lines - line array 
%
%     if fails, return 0
%
%     Yuxi 07.18.2000
%
%     $ Version 1.0 - Yuxi 07.18.2000 - initial version $

function [lines] = fload_log(filename);

% open file
[fid,message] = fopen(filename,'rt');
if fid < 0
   fprintf('\n%s\n',message);
   lines = 0;
   return;
end

% load file into str
str = fscanf(fid,'%c');

% close file
fclose(fid);

% convert str to line cell array
lines = str2cell(str);
%list = str2num(str);

return
