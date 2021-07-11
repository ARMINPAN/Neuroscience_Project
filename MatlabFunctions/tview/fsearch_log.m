% FSEARCH_LOG               Retrieve information from f21 log lines
% 
%     value = fsearch_log(lines,section,keyword,default,prompt_not_found);
%
%     INPUTS
%     lines      - log line array (return value of fload_log)
%     section    - section name (string) in log file (like [XXX])
%     keyword    - entry name (string) in log file
%     defualt    - return value (string) if expected section-keyword pair not found
%  
%     OUTPUTS
%     value - string returned 
%
%     Yuxi 07.18.2000
%
%     $ Version 1.0 - Yuxi 07.18.2000 - initial version $

function value = fsearch_log(lines,section,keyword,default,prompt_not_found);

if nargin < 4
   fprintf('\nFSEARCH_LOG, no enough input arguments, type ''help fsearch_log'' for help\n\n');
   value = default;
   return;
end

if nargin < 5
   prompt_unfound = 0;
else
   prompt_unfound = prompt_not_found;
end

% length of keyword segment in log file
div = 30;

% flag and counter
count = 1;

% convert section name 'XXX' to '[XXX]' 
section_str = sprintf('[%s]',section);

% not found message
not_found_msg = sprintf('\n  %s\n',['fsearch_log, ' section ', ' keyword ', not found !']);

% get length line cell array
numlines = length(lines);

% Loop through the cell array until section_str and keyword are found
while 1
   % check if exceed lines dimension
   if count > numlines
      if prompt_unfound fprintf(not_found_msg); end
      value = sprintf('%s',default);
      return;
   end
   
   % search section
   if isempty(lines{count})
      % Do nothing if blank line
      count = count + 1;
   elseif strcmp(deblank(lines{count}),section_str)
      count = count + 1;
      while 1
         if count > numlines
            if prompt_unfound fprintf(not_found_msg); end
            value = sprintf('%s',default);
            return;
         end
         
         % search keyword
         if isempty(lines{count})
            count = count +1;
         elseif strcmp(lines{count}(1),'[')
            break;
         elseif strcmp(deblank(lines{count}(1:div)),keyword)
            value = lines{count}(div+1:length(lines{count}));
       %     value = strjust(value,'left');
            value = deblank(value);
            return;
         else
            count = count + 1;
         end
      end
   else
      count = count + 1; 
   end
end

return
