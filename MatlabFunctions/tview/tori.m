% TORI		Analyze orientation tuning curve data
% 
%     [tori_info] = tori(flog,cluster_index);
%
%     INPUTS
%     flog          - structure returned by tview
%     cluster_index - index of the cluster you want to check
%
%     OUTPUTS
%     tori_info    - structure with the following fields:
%       rr      - sorted spike histogram for drifting gratings
%       Pxx     - matrix of power spectral density at each direction
%       relmod  - relative modulation
%
%     yuxi 09.26.00, modified brian's program to take tview's output as input
%                    corrected possible errors in the function of bintimes()
%
%     --------------------- brian's version information ---------------------
%
%     brian 09.16.99
%     $ Revision 1.0 - brian 04.29.00 - cleaned up, fixed bugs $

function [tori_info] = tori(flog,cluster_index);

% Constants
FS = 10000;                         % Assumed sampling frequency
SMOOTHPSD = 0;                      % Set to 1 to smooth psd
PADFFT = 1;                         % Set to 1 to pad data to nextpow2, for fast-Fourier transform algorithm

if ~flog.isvalid == 1
   fprintf('\nERROR! The flog you are trying to analyze is invalid.\n\n');
   tori_info.error = 'invalid flog';
   return
end

if ~strcmp(flog.test_type,'tuning curve') ...
      | ~strcmp(flog.tc_mode,'direction') ...
      | ~strcmp(flog.direction_test_mode,'default') 
   fprintf('\nERROR! This program only supports default orientation test.\n');
   tori_info.error = 'invalid test type';      
   return
end

if nargin < 2 
   spike_file_index = 1;
else
   if cluster_index > length(flog.spike_files)
      fprintf('\nERROR! The cluster index %d you inputed is invalid.\n\n',cluster_index);
      tori_info.error = 'invalid cluster index';      
      return;
   else
      spike_file_index = cluster_index;
   end
end

%----- Get the spikes
spk = flog.spikes{spike_file_index};
spk = spk';

SPATIAL_FREQUENCY = flog.gratings_spatial_frequency;
VELOCITY = flog.gratings_velocity;
FRAME_RATE = flog.remote_refresh_rate;		% use remote rr because spk has been corrected by remote rr
FRAME_DT = 1/FRAME_RATE;       	      	% Interframe interval, seconds
GRAT_TEMP_FREQUENCY = SPATIAL_FREQUENCY*VELOCITY;
NUMDIRS = flog.direction_number; 		   % Number of unique directions
DIRLIST = (flog.test_sequence(:,1)*(360/flog.direction_number))';   % Original direction sequence
SINGLE_TIME = flog.single_test_time;      % Time each direction is played, seconds
INTERVAL = flog.interval;           		% Time between different directions, seconds
		                                    % the grating is static during this interval
                                    
NFRAMES = ceil(FRAME_RATE*NUMDIRS*(SINGLE_TIME+INTERVAL));
SKIP = round(INTERVAL/FRAME_DT);    % # of frames over which grating is static
DUR  = round(SINGLE_TIME/FRAME_DT); % # of frames over which the grating is moving

%-- Bin the tuning spike data
%r = bintimes(spk,FRAME_DT*FS,NFRAMES); % it seems that the function bintimes misses some spikes

% bin spk
r = zeros(NFRAMES,1);
for i = 1:length(spk)
   i_temp = ceil(spk(i)/(FRAME_DT*FS));
   if i_temp <= NFRAMES
      r(i_temp) = r(i_temp) + 1;
   end
end

%clear spk logfile flog

%----- Get spontaneous rate if available
%if nargin == 2
%   spon = fget_data(fname2);
%   spon = mean(spon);
%else
   %-- assume zero if not available
%   spon = 0;
%end

%----- Bin the spike rate by orientation
%-- Preallocate arrays with rows for rate and colums for orientations
rr = zeros(ceil(SINGLE_TIME/FRAME_DT),NUMDIRS);   % response while moving
ss = zeros(round(INTERVAL/FRAME_DT),NUMDIRS);     % response while being static

%-- Handle the first grating, which has a pause of Interval/2
temp = r(round(SKIP/2):round(SKIP/2)+DUR);        % 'r' is histogram
rr(1:length(temp),1) = temp;

%-- The rest of the directions are separated by static gratings which
%-- for the first half is the previous orientation, and for the second
%-- half is the next orientation.
for i = 2:NUMDIRS
   %-- Grab the drifting frames
   ind = round(SKIP/2) + (i-1)*DUR + (i-1)*SKIP;
   temp = r(ind:ind+DUR);
   rr(1:length(temp),i) = temp;
   %-- Grab the static frames
   sind = round(SKIP/2) + (i-1)*DUR;
   temp = r(sind+1:sind+SKIP);
   ss(1:length(temp),i) = temp;
end

%-- Collapse over grating presentations
rsum = sum(rr);    % sum over orientations
ssum = sum(ss);    % sum over orientations

%-- Sort into ascending order
[DIRLIST,ind] = sort(DIRLIST);
rsum = rsum(ind);
rr = rr(:,ind);

ssum = ssum(ind);
ss = ss(:,ind);

%----- Calculate the relative modulation
%-- Subtract spontaneous rate
%r = rr - spon;
r = rr;

%-- Here's the psd, this is computed for the binned rate at
%-- every separate orientation
if PADFFT
   nfft = 2^nextpow2(length(r));
else
   nfft = length(r);
end
fftr = fft(r,nfft);
numuniquepoints = ceil((nfft+1)/2);
fftr = fftr(1:numuniquepoints,:);
magr = 2*abs(fftr);
magr(1,:) = magr(1,:)/2;
if ~rem(nfft,2),
   magr(length(magr),:) = magr(length(magr),:)/2;
end
magr = magr/nfft;
f = (0:numuniquepoints-1)*2/nfft;
f = f*(FRAME_RATE/2);
if SMOOTHPSD
   Pxx = filter([.3 .3 .3],1,magr);  
else
   Pxx = magr;
end

%-- The driving frequency isn't always at a transform point, so 
%-- we find the indices above and below it, rm is calculated for
%-- the orientation with the maximal response only
maxind = find(rsum==max(rsum));
Pmax = Pxx(:,maxind(1));
indL = find(f < GRAT_TEMP_FREQUENCY);
indU = find(f > GRAT_TEMP_FREQUENCY);

relmodL = Pmax(indL(length(indL)))/Pmax(1);
relmodU = Pmax(indU(1))/Pmax(1);
relmod = (relmodU+relmodL)/2;

%-- Direction index
nulldir = mod(maxind(1)+length(DIRLIST)/2,length(DIRLIST));
% added by Yuxi Fu on 1/9/01
if nulldir==0 
   nulldir = length(DIRLIST);
end
% added by Yuxi Fu on 1/9/01

r_pref = mean(r(:,maxind(1)));
r_null = mean(r(:,nulldir));
dirind = (r_pref - r_null)/(r_pref + r_null);

temp = conv([.3 .3 .3],rsum);
temp = temp(2:end-1);
r_pref = temp(maxind(1))/length(r);
r_null = temp(nulldir)/length(r);
dirind_smooth = (r_pref - r_null)/(r_pref + r_null);

%----- Set up outputs
%if nargout
	tori_info.test_name = flog.test_name;
   tori_info.spike_file_index = spike_file_index;
   tori_info.spike_file = flog.spike_files{spike_file_index};
   tori_info.temporal_freq = GRAT_TEMP_FREQUENCY;
   tori_info.spatial_freq = SPATIAL_FREQUENCY;
   tori_info.rr = rr;
   tori_info.rsum = rsum;
   tori_info.ss = ss;
   tori_info.ssum = ssum;
   tori_info.Pxx = Pxx;
   tori_info.f = f;
   tori_info.relmodL = relmodL;
   tori_info.relmodU = relmodU;
   tori_info.relmod = relmod;
   tori_info.dirind = dirind;
   tori_info.dirind_smooth = dirind_smooth;
   tori_info.prefdir = DIRLIST(maxind(1));
	tori_info.nulldir = DIRLIST(nulldir);
   tori_info.prefind = maxind(1);
   tori_info.nullind = nulldir;
%end

% export output
out_file_name = sprintf('%s.tori.mat',tori_info.spike_file(1:12));
save(out_file_name,'tori_info');

%----- Plot the results
%if VERBOSE & nargout == 0
figure('NumberTitle','off','Name',tori_info.spike_file,'Position',[rand*100+50 rand*150+100 700 400]);

   %-- Polar plot of tuning
   subplot(231)
   set(gca,'Position',[0.02 0.55 0.38 0.40],'Box','On');
   
   [x,y] = pol2cart(DIRLIST*pi/180,rsum);
   x = x(:);
   y = y(:);
   z = (x + y.*sqrt(-1)).';
   [th,r] = cart2pol(real(z),imag(z));
   th = [th,th(1)];
   r = [r,r(1)];
   h = polar(th,r,'k-');
   %h = compass(x,y,'k-');
   set(h,'LineWidth',1.5);
   ylabel('Spikes');
   %   title(tori_info.spike_file);
   
   %-- Cartesian plot of tuning
   subplot(232)
   set(gca,'Position',[0.43 0.60 0.23 0.32],'Box','On');
   plot(DIRLIST,rsum,'k-','LineWidth',1.5);
   ylabel('Spikes');
   xlabel('Orientation (degrees)');
   axis([0 max(DIRLIST) 0 max(rsum)]);
   set(gca,'Xtick',DIRLIST(1:4:length(DIRLIST)));
   grid on
   
   txt_info{1} = sprintf('%s',tori_info.spike_file);
   txt_info{2} = '';
   txt_info{3} = '';

   txt_info{4} = sprintf('Temporal freq = %0.3f hz/s',tori_info.temporal_freq);
   txt_info{5} = sprintf('Spatial freq = %0.3f hz/cm',tori_info.spatial_freq);
   txt_info{6} = sprintf('Velocity = %0.3f cm/s',flog.gratings_velocity);
   
   txt_info{7} = '';
   txt_info{8} = sprintf('Preferred Dir = %d',tori_info.prefdir);
   txt_info{9} = sprintf('Null Dir = %d',DIRLIST(nulldir));
   txt_info{10} = sprintf('Dir Index = %0.3f',tori_info.dirind);
   
   txt_info{11} = '';
   txt_info{12} = sprintf('Relative modulation = %0.3f',tori_info.relmod);
   if tori_info.relmod < 1
      txt_info{13} = sprintf('Cell type = complex');
   else
      txt_info{13} = sprintf('Cell type = simple');
   end
     
   text(max(DIRLIST)*1.2,max(rsum)*1.0,txt_info,'VerticalAlignment','top','HorizontalAlignment','left');
   
%   box off
   
   %-- Plot of psd, w/ F1 and F2 marked
   subplot(234)
   set(gca,'Position',[0.10 0.12 0.23 0.32],'Box','On');

   plot(f,Pmax,'k-','LineWidth',1.5);
   hold on; %keyboard
   plot([GRAT_TEMP_FREQUENCY GRAT_TEMP_FREQUENCY],[max(Pmax)*0.025 max(Pmax)*0.975],'r-.');
   plot([2*GRAT_TEMP_FREQUENCY 2*GRAT_TEMP_FREQUENCY],[max(Pmax)*0.025 max(Pmax)*0.975],'r-.');   
   ylabel('Magnitude');
   xlabel('Temporal frequency');   
   axis([0 3*GRAT_TEMP_FREQUENCY 0 max(Pmax)]);
   title(['RM = ' num2str(relmod)]);
   grid on
%   box off
   
   %-- Plot of the spike trains, sorted by direction
   %-- the end of each grating period is also marked
   subplot(235)
   set(gca,'Position',[0.43 0.12 0.23 0.32],'Box','On');
   hold on
   for i = 1:NUMDIRS
      temp = rr(:,i);
      ind = find(temp>=1);
      plot([1 length(rr)],[i i],'k-');
      plot(ind,temp(ind)+i-1,'k.','MarkerSize',6);
   end

   marks = floor(SINGLE_TIME/(1/GRAT_TEMP_FREQUENCY));
   for i = 1:marks
      ind = [i*(1/GRAT_TEMP_FREQUENCY)*FRAME_RATE i*(1/GRAT_TEMP_FREQUENCY)*FRAME_RATE];
      plot([ind],[0 NUMDIRS],'r-.');
   end
   
   xlabel('Time (seconds)');
   ylabel('Orientation (degrees)');
   axis([1 length(rr) 1 NUMDIRS]);
   set(gca,'Ytick',[1:3:NUMDIRS],'Yticklabel',DIRLIST(1:3:NUMDIRS));
   set(gca,'Xtick',[0:length(rr)/SINGLE_TIME:length(rr)],'Xticklabel',0:5);
   %   grid on; box off; grid off;
   grid on

%   suptitle(fname);
   
%   fprintf('  Cell : %s\n',fname);
%   fprintf('  Temporal frequency : %2.4f\n',GRAT_TEMP_FREQUENCY);
%   fprintf('  Relative mdoulation (lower) : %2.4f\n',relmodL);
%   fprintf('  Relative mdoulation (upper) : %2.4f\n',relmodU);
%   fprintf('  Direction index : %2.4f\n',dirind);
%end

return