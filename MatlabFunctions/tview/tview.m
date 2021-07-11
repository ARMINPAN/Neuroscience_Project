% TVIEW               TUNING CURVE VIEWER
% 
%     function flog = tview(filename,channels);
%
%     INPUTS
%     filename   - log file name (string) 
%     channels   - channels, must be a array, like [0], [2 5], [6:9], [4:6 9 10]
%                  default is channel 0-25, [0:25]
%  
%     OUTPUTS
%     flog - struture in which log file infomation and result are saved
%
%     Yuxi 07.18.2000
%
%     $ Version 1.0 - Yuxi 07.18.2000 - initial version $
%     $ Version 2.0 - Yuxi 11.23.2001 - revised version $
%     $ Version 2.x - Yuxi 10.23.2009 - for CRCNS.org, so will work with previous file format $

function flog = tview(filename,channels);

% get log file name and path if nargin < 1
if nargin < 1
   [log_file_name, path] = uigetfile('*.log','Open');
   if log_file_name == 0 return; end
   channel_used = double('a'):double('z');
else
   if ~ischar(filename)
      fprintf('\nInput argument has to be a string. type ''help tview'' for help\n\n');
      return;
   end
   path = pwd;
   log_file_name = filename;
   
   if nargin < 2
       channel_used = double('a'):double('z');
   else
       channel_used = channels+'a';
   end
end

flog = fretrieve_log(path,log_file_name,channel_used);
if ~flog.isvalid
   fprintf('\n\nCan''t retrieve data from the log file %s.\n',log_file_name);
   fprintf('This program is ONLY for checking tuning curve test result.\n');
   fprintf('Contact Author if you have further question.\n');
   fprintf('Type ''help tview'' for more information.\n');
   return;
end

if strcmp(flog.test_type,'tuning curve') ...
      & strcmp(flog.tc_mode,'direction') ...
      & strcmp(flog.direction_test_mode,'default') 
   for i = 1:length(flog.spike_files)
      ori_info = tori(flog,i);
      flog.ori_info{i} = ori_info;
   end
   return;
end

% fig = figure;
fig = figure('NumberTitle','off','Name',flog.test_name,'Position',[rand*200+100 rand*150+100 480 360]);

% add menu items to control axis scale mode 
hm_sep = uimenu(fig,'Label','      ','Enable','off');
if ~strcmp(flog.tc_mode,'direction')
   hm_axis = uimenu(fig,'Label','&Axis','ForeGroundColor','g');
   
   if strcmp(flog.tc_mode,'spatial frequency') | strcmp(flog.tc_mode,'temporal frequency')
      hm_x_linear = uimenu(hm_axis,'Label','X Linear','Callback',['set(gca,''XScale'',''linear'')']);
      hm_x_log = uimenu(hm_axis,'Label','X Log','Callback',['set(gca,''XScale'',''log'')']);
   end
      
   hm_y_linear = uimenu(hm_axis,'Label','Y Linear','Callback',['set(gca,''YScale'',''linear'')']);
   hm_y_log = uimenu(hm_axis,'Label','Y Log','Callback',['set(gca,''YScale'',''log'')']);
end

% get subplot dimensions (m by n)
sub_plot_n = ceil(sqrt(length(flog.spike_files)));
if sub_plot_n*(sub_plot_n-1) >= length(flog.spike_files)
   sub_plot_m = sub_plot_n-1;
else
   sub_plot_m = sub_plot_n;
end

average = flog.sum/flog.repeats;

for i = 1:length(flog.spike_files)
   subplot(sub_plot_m,sub_plot_n,i);
   
   switch flog.tc_mode
   case 'pos x'
      x = (1:1:flog.data_points);
      y = average(i,:);
      e = flog.stderrs(i,:);
      errorbar(x,y,e,'o-');
      xlabel('X Pos');
      ylabel('Mean Spikes');
   case 'pos y'
      x = (1:1:flog.data_points);
      y = average(i,:);
      e = flog.stderrs(i,:);
      errorbar(x,y,e,'o-');
      xlabel('Y Pos');
      ylabel('Mean Spikes');
   case 'mask'
      x = (1:1:flog.data_points);
      x = (x-1)/(flog.data_points-1)*100;
      y = average(i,:);
      e = flog.stderrs(i,:);
      errorbar(x,y,e,'o-');
      plot(x,y,'o-');
      xlabel('Mask Radius (%)');
      ylabel('Mean Spikes');
   case 'spatial frequency'
      x = flog.spatial_list;
      y = average(i,:);
      e = flog.stderrs(i,:);
      errorbar(x,y,e,'o-');
      xlabel('Spatial Frequency');
      ylabel('Mean Spikes');
   case 'temporal frequency'
      x = flog.temporal_list;
      y = average(i,:);
      e = flog.stderrs(i,:);
      errorbar(x,y,e,'o-');
      xlabel('Temporal Frequency');
      ylabel('Mean Spikes');
   case 'direction'
      switch flog.direction_test_mode
      case 'default'
         x = (0:2*pi/flog.data_points:2*pi);
         y = [average(i,:),average(i,1)];
         polar(x,y);
         xlabel('Direction');
         ylabel('Mean Spikes');
      case 'customized'
         angles = flog.direction_list/180*pi;
         x = average(i,:).*cos(angles');
         y = average(i,:).*sin(angles');
         compass(x,y);
         xlabel('Direction');
         ylabel('Mean Spikes');
      end
   end
   
   title(flog.spike_files(i));
end

return;
