function [cBeat, wObj] = finalBt(wObj, btOpt, showPlot)


if isstr(wObj), wObj=waveFile2obj(wObj); end
wObj.signal=mean(wObj.signal, 2);	% Stereo ==> Mono

if ~isfield(wObj, 'gtBeat')
	wObj.gtBeat=btGtRead(wObj.file);
end
if ~isfield(wObj, 'osc')
	wObj.osc=wave2osc(wObj, btOpt.oscOpt, showPlot);	% Return the onset strength curve (novelty curve)
end

frame=wObj.osc.signal;
%frame=frame-mean(frame);
if ~isfield(wObj, 'acf'), wObj.acf=frame2acf(wObj.osc.signal, length(wObj.osc.signal), btOpt.acfMethod); end
timeStep=wObj.osc.time(2)-wObj.osc.time(1);
n1=round(60/btOpt.bpmMax/timeStep)+1;
n2=round(60/btOpt.bpmMin/timeStep)+1;
acf2=wObj.acf;
acf2(1:n1)=-inf;
acf2(n2:end)=-inf;
[maxFirst, bp]=max(acf2);	% First maximum
if btOpt.useDoubleBeatConvert
	factor=2;
	indexCenter=round((bp-1)/factor+1);
	sideSpread=round((indexCenter-1)*0.1);
	left=indexCenter-sideSpread; if left<1; left=1; end
	right=indexCenter+sideSpread; if right>length(wObj.acf), right=length(wObj.acf); end
	[maxInRange, bpLocal]=max(acf2(left:right));
	if (maxFirst-maxInRange)/maxFirst<btOpt.peakHeightTol
		bp=bpLocal+left-1;
	end
end
if btOpt.useTripleBeatConvert
	factor=3;
	indexCenter=round((bp-1)/factor+1);
	sideSpread=round((indexCenter-1)*0.1);
    left=indexCenter-sideSpread; if left<1; left=1; end
	right=indexCenter+sideSpread; if right>length(wObj.acf), right=length(wObj.acf); end
	[maxInRange, bpLocal]=max(acf2(left:right));
	if (maxFirst-maxInRange)/maxFirst<btOpt.peakHeightTol
		bp=bpLocal+left-1;
	end
end
bp=bp-1;	% Beat period
bpm=60/(bp*timeStep);
tempoCurve=bpm;		% For constant tempo, tempoCurve is only a single value of BPM.
opt.trialNum=btOpt.trialNum;
opt.wingRatio=btOpt.wingRatio;
cBeatSet=periodicMarkId(frame, bp, opt, showPlot);
[~, maxIndex]=max([cBeatSet.weight]);
beatPos=cBeatSet(maxIndex).position;
cBeat=beatPos*timeStep;
globalMaxIndex=cBeatSet(maxIndex).globalMaxIndex;
if showPlot
   	figure
    subplot(311);
   	frameSize=round(31.25/1000*wObj.fs);
   	overlap=0;
   	[y,f,t,p] = spectrogram(wObj.signal,256,0,1024);
   	surf(t,f,10*log10(abs(p)),'EdgeColor','none');   
   	axis xy; axis tight; colormap(jet); view(0,90);
   	xlabel('Time');
   	ylabel('Frequency (Hz)');
   	subplot(312); plot(frame); set(gca, 'xlim', [-inf inf]);
   	line(globalMaxIndex, frame(globalMaxIndex), 'marker', 'square', 'color', 'k');
   	line(beatPos, frame(beatPos), 'marker', '.', 'color', 'm', 'linestyle', 'none');
%  	if isfield(wObj, 'gtBeat')		% Plot the GT beat
%   	gtBeat=wObj.gtBeat{1};
%   	axisLimit=axis;
%   	for i=1:length(gtBeat)
%           line(gtBeat(i)/timeStep*[1 1], axisLimit(3:4), 'color', 'r'); 
%       end
%   end
    title('Novelty curve with computed beat positions');
    subplot(313); plot(wObj.acf); set(gca, 'xlim', [-inf inf]);
    axisLimit=axis;
    line(n1*[1 1], axisLimit(3:4), 'color', 'r');
    line(n2*[1 1], axisLimit(3:4), 'color', 'r');
    line(bp+1, wObj.acf(bp+1), 'marker', 'square', 'color', 'k');
    title('Auto-correlation of the novelty curve');
end

fMeasure=[];

% Assign everything to wObj
wObj.cBeatSet=cBeatSet;
wObj.fMeasure=fMeasure;
wObj.cBeat=cBeat;

end

