% FRETRIEVE               Retrieve info from logfile
% 
%     function flog = fretrieve(path,filename);
%
%     INPUTS
%     path       - log file path (string)
%     filename   - log file name (string)
%  
%     OUTPUTS
%     flog       - structure containing log file info
%
%     Yuxi 07.18.2000
%
%     $ Version 1.0 - Yuxi 07.18.2000 - initial version $

function flog = fretrieve(path,filename);

SPIKE_FILE_HEADER_SIZE_IN_BYTE = 828;

log_file_name = filename;

flog.path = path;
flog.log_file_name = log_file_name;

% load log file data
log_file_full_name = fullfile(path,log_file_name);
log_lines = fload_log(log_file_full_name);

if ~iscellstr(log_lines)
   errordlg('Can''t load log file data correctly.','File Load Error','replace')
   flog.isvalid = 0;
   return;
end

% search log file data 
file_type = fsearch_log(log_lines,'FileInfo','FileType','JQK');
if ~strcmp(file_type,'f21lv test log file')
   errordlg('This is not a valid f21 log file.','File Type Error','replace')
   flog.isvalid = 0;
   return
end
flog.file_type = file_type;

file_version = fsearch_log(log_lines,'FileInfo','FileVersion','JQK');
if ~strcmp(file_version,'2.0')
   errordlg('Only version 2.0 log file is supported.','File Version Error','replace')
   flog.isvalid = 0;
   return
end
flog.file_version = file_version;

test_type = fsearch_log(log_lines,'TestInfo','TestType','JQK');
if ~strcmp(test_type,'tuning curve')
   errordlg('This is not a tuning curve test log file.','Test Type Error','replace')
   flog.isvalid = 0;
   return
end
flog.test_type = test_type;

test_name = fsearch_log(log_lines,'TestInfo','Testname','JQK');
flog.test_name = test_name;

str_temp = fsearch_log(log_lines,'TestInfo','RemoteRefreshRate','1');
remote_refresh_rate = sscanf(str_temp,'%f');
flog.remote_refresh_rate = remote_refresh_rate;

str_temp = fsearch_log(log_lines,'TestInfo','RefreshRate','1');
refresh_rate = sscanf(str_temp,'%f');
flog.refresh_rate = refresh_rate;

tc_mode = fsearch_log(log_lines,'TunningCurve','TCMode','JQK');
if strcmp(tc_mode,'JQK')
   errordlg('This is not a new-style tuning curve test log file.','TC Type Error','replace')
   flog.isvalid = 0;
   return
end
flog.tc_mode = tc_mode;

gratings_type = fsearch_log(log_lines,'TunningCurve','GratingsType','JQK');
flog.gratings_type = gratings_type;

str_temp = fsearch_log(log_lines,'TunningCurve','OriX','9999');
ori_x = sscanf(str_temp,'%f');
flog.ori_x = ori_x;

str_temp = fsearch_log(log_lines,'TunningCurve','OriY','9999');
ori_y = sscanf(str_temp,'%f');
flog.ori_y = ori_y;

str_temp = fsearch_log(log_lines,'TunningCurve','GratingsW','9999');
gratings_w = sscanf(str_temp,'%f');
flog.gratings_w = gratings_w;

str_temp = fsearch_log(log_lines,'TunningCurve','GratingsH','9999');
gratings_h = sscanf(str_temp,'%f');
flog.gratings_h = gratings_h;

str_temp = fsearch_log(log_lines,'TunningCurve','GratingsSpatialFrequency','9999');
gratings_spatial_frequency = sscanf(str_temp,'%f');
flog.gratings_spatial_frequency = gratings_spatial_frequency;

str_temp = fsearch_log(log_lines,'TunningCurve','GratingsVelocity','9999');
gratings_velocity = sscanf(str_temp,'%f');
flog.gratings_velocity = gratings_velocity;

str_temp = fsearch_log(log_lines,'TunningCurve','BarW','9999');
bar_w = sscanf(str_temp,'%f');
flog.bar_w = bar_w;

str_temp = fsearch_log(log_lines,'TunningCurve','BarH','9999');
bar_h = sscanf(str_temp,'%f');
flog.bar_h = bar_h;

str_temp = fsearch_log(log_lines,'TunningCurve','InnerDirection','9999');
inner_direction = sscanf(str_temp,'%f');
flog.inner_direction = inner_direction;

str_temp = fsearch_log(log_lines,'TunningCurve','OuterDirection','9999');
outer_direction = sscanf(str_temp,'%f');
flog.outer_direction = outer_direction;

circle_mask = fsearch_log(log_lines,'TunningCurve','CircleMask','JQK');
flog.circle_mask = circle_mask;

str_temp = fsearch_log(log_lines,'TunningCurve','SingleTestTime','1');
single_test_time = sscanf(str_temp,'%d');
flog.single_test_time = single_test_time;

str_temp = fsearch_log(log_lines,'TunningCurve','Interval','0');
interval = sscanf(str_temp,'%d');
flog.interval = interval;

str_temp = fsearch_log(log_lines,'TunningCurve','Repeats','1');
repeats = sscanf(str_temp,'%d');
flog.repeats = repeats;

str_temp = fsearch_log(log_lines,'TunningCurve','DataPoints','1');
data_points = sscanf(str_temp,'%d');
flog.data_points = data_points;

direction_test_mode = fsearch_log(log_lines,'TunningCurve','DirectionTestMode','JQK');
flog.direction_test_mode = direction_test_mode;

str_temp = fsearch_log(log_lines,'TunningCurve','DirectionNumber','2');
direction_number = sscanf(str_temp,'%d');
flog.direction_number =direction_number;

str_temp = fsearch_log(log_lines,'TunningCurve','DirectionList','1 0');
list_temp = sscanf(str_temp,'%f');
direction_list = list_temp(2:length(list_temp));
flog.direction_list = direction_list;

str_temp = fsearch_log(log_lines,'TunningCurve','SpatialList','1 0');
list_temp = sscanf(str_temp,'%f');
spatial_list = list_temp(2:length(list_temp));
flog.spatial_list = spatial_list;

str_temp = fsearch_log(log_lines,'TunningCurve','TemporalList','1 0');
list_temp = sscanf(str_temp,'%f');
temporal_list = list_temp(2:length(list_temp));
flog.temporal_list = temporal_list;

str_temp = fsearch_log(log_lines,'TunningCurve','TestSequence','1 0');
list_temp = sscanf(str_temp,'%f');
test_sequence = list_temp(2:length(list_temp));
flog.test_sequence = test_sequence;

% search spike dat file. max channel, 26(a-z); max cluster, 6(0-5)
count = 0;
for i='a':'z'
   channel_on = 0;
   for j=0:5
      keyword = sprintf('SpikeFile%c%d',i,j);
      spike_file = fsearch_log(log_lines,'DataFile',keyword,'JQK',0);
      if ~strcmp(spike_file,'JQK')
         channel_on = 1;
         count = count + 1;
         spike_files{count} = sscanf(spike_file,'%s',1);
      end
   end
   if channel_on==0 break; end
end
flog.spike_files = spike_files;

% load spike file data
num_spike_files = length(spike_files);

for n = 1: num_spike_files
   spk_file_full_name = fullfile(path,spike_files{n});
   
   fid = fopen(spk_file_full_name,'rb');
   fseek(fid,SPIKE_FILE_HEADER_SIZE_IN_BYTE,'bof');
   data = fread(fid,inf,'int32');
   fclose(fid);
   
   data = data*refresh_rate/remote_refresh_rate;  % convert to remote time
   spikes{n} = data;
end
flog.spikes = spikes;

% create arrays initialized with zero
sum = zeros(num_spike_files,data_points);
individuals = zeros(num_spike_files,repeats,data_points);

for i = 1:num_spike_files
   for j = 1: length(spikes{i})
      spike = spikes{i}(j);
      spike = spike/10/1000; % convert to sec 
      
      full_step = single_test_time + interval;
      step_index = floor(spike/full_step);
      spike_remain = spike - step_index*full_step;
      step_index = step_index + 1;
      if spike_remain>(interval*0.5) & spike_remain<(interval*0.5+single_test_time)
         if step_index <= length(test_sequence)
            sum(i,test_sequence(step_index)+1) = sum(i,test_sequence(step_index)+1) + 1;
            
            repeat_index = ceil(step_index/data_points);
            individuals(i,repeat_index,test_sequence(step_index)+1) = individuals(i,repeat_index,test_sequence(step_index)+1) + 1;
         end
      end
   end
end

flog.sum = sum;
flog.individuals = individuals;

% create standard deviation array
stds = zeros(num_spike_files,flog.data_points);

for i = 1:num_spike_files
   if repeats>1
      array_temp(:,:) = flog.individuals(i,:,:);
      std_temp = std(array_temp);
      stds(i,:) = std_temp;
   end
end

flog.stds = stds;
flog.stderrs = stds/sqrt(repeats);

flog.isvalid = 1;

return

