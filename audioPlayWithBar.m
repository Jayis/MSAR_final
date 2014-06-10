function h=audioPlayWithBar(wObj)
%audioPlayWithBar: Audio play with progressive bars
%
%	Usage:
%		h=audioPlayWithBar(wObj)
%
%	Example:
%		waveFile='twinkle_twinkle_little_star.wav';
%		wObj=waveFile2obj(waveFile);
%		time=(1:length(wObj.signal))/wObj.fs;
%		subplot(211);
%		plot(time, wObj.signal); axis([min(time), max(time), -1, 1]);
%		ylabel('Amplitude');
%		subplot(212);
%		frameSize=256;
%		overlap=frameSize/2;
%		[S,F,T]=spectrogram(wObj.signal, frameSize, overlap, 4*frameSize, wObj.fs);
%		imagesc(T, F, log(abs(S))); axis xy
%		xlabel('Time (sec)');
%		ylabel('Freq (Hz)');
%		wavePlayButton(wObj);	% audioPlayWithBar is called within this function!

%	Roger Jang, 20130224

if nargin<1, selfdemo; return; end
if ischar(wObj), wObj=waveFile2obj(wObj); end		% wObj is actually the wave file name
if wObj.amplitudeNormalized, wObj.signal=double(wObj.signal)/(2^wObj.nbits/2); end; 

% === Find all axes and create all progressive bars
axesH=findobj(gcf, 'type', 'axes');
for i=1:length(axesH)
	set(gcf, 'currentAxes', axesH(i));
	axisLimit=axis(axesH(i));
	barH(i)=line(nan*[1 1], axisLimit(3:4), 'color', 'r', 'erase', 'xor', 'linewidth', 1);
end
% === Play audio
p=audioplayer(wObj.signal, wObj.fs);
currTime=0;
timerPeriod=0.05;
% === Store everything for display in U
U=get(gco, 'userData'); U.barH=barH; U.currTime=currTime; U.timerPeriod=timerPeriod; set(gco, 'userData', U);
set(p, 'TimerFcn', 'U=get(gco, ''userData''); U.currTime=U.currTime+U.timerPeriod; set(U.barH, ''xdata'', U.currTime*[1 1]); set(gco, ''userData'', U);');
set(p, 'TimerPeriod', timerPeriod);
set(p, 'stopFcn', 'U=get(gco, ''userData''); delete(U.barH);');
playblocking(p);	% You need to use playblocking()!

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);
