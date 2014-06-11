function [ bPair ] = getSongPair( SongList )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if length(SongList) == 1 % demo one
    waveFile = SongList{1};
    wObj = waveFile2obj(waveFile);
    btOpt = myBtOptSet;
    showPlot = 1;
    cBeat = myBt(wObj, btOpt, showPlot);
    bPair = cBeat;
%   tempWaveFile=[tempname, '.wav'];
%	tickAdd(wObj, bPair, tempWaveFile);
%	dos(['start ', tempWaveFile]);
else
    for i = 1:length(SongList) - 1
        for j = i:length(SongList)
            waveFile1 = SongList{i};
            wObj1 = waveFile2obj(waveFile1);
            btOpt = myBtOptSet;
            showPlot = 0;
            cBeat1 = myBt(wObj1, btOpt, showPlot);
            waveFile2 = SongList{j};
            wObj2 = waveFile2obj(waveFile2);
            cBeat2 = myBt(wObj2, btOpt, showPlot);
            if length(cBeat1) > length(cBeat2)
                bPair = zeros(length(cBeat1), 2);
                bPair = bPair - 1;
                for k = 1:length(cBeat1)
                   bPair(k, 1) = round(cBeat1(k) * wObj1.fs);
                    if k <= length(cBeat2)
                       bPair(k, 2) = round(cBeat2(k) * wObj2.fs);
                   end
                end
            elseif length(cBeat1) < length(cBeat2)
                bPair = zeros(length(cBeat2), 2);
                bPair = bPair - 1;
                for k = 1:length(cBeat2)
                   bPair(k, 2) = round(cBeat2(k) * wObj2.fs);
                    if k <= length(cBeat1)
                       bPair(k, 1) = round(cBeat1(k) * wObj1.fs);
                   end
                end
            else
                bPair = zeros(length(cBeat1), 2);
                bPair = bPair - 1;
                for k = 1:length(cBeat1)
                   bPair(k, 1) = round(cBeat1(k) * wObj1.fs);
                   bPair(k, 2) = round(cBeat2(k) * wObj2.fs);
                end
            end
        end
    end
end

end

