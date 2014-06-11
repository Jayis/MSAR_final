addpath C:\Users\Harry\Documents\MATLAB\utility
addpath C:\Users\Harry\Documents\MATLAB\sap
addpath C:\Users\Harry\Documents\MATLAB\machineLearning


input1 = 'input/1st.wav';
input2 = 'input/2nd.wav';

wObj1 = waveFile2obj(input1);
wObj2 = waveFile2obj(input2);

y1 = wObj1.signal;
y2 = wObj2.signal;

inList = {input1 input2};

bpair = getSongPair (inList);

% cut head
head = bpair(1,2) - bpair(1,1);
if head > 0
    y2(1:head) = [];
    bpair(:,2) = bpair(:,2) - head;
elseif head < 0
    head = -head;
    y1(1:head) = [];
    bpair(:,1) = bpair(:,1) - head;
end

wObj1.signal = y1;
wObj2.signal = y2;

clear y1;

% sync segment 1-by-1
tempObj = wObj2;
for i = 1: size(bpair, 1)-1
    i
    tempObj.signal = y2(bpair(i, 2): bpair(i+1,2),1);
    
    former = y2(1:bpair(i,2)-1,1);
    latter = y2(bpair(i+1,2)+1:length(y2),1);
    
    targetL = bpair(i+1, 1) - bpair(i, 1)+1;
    sourceL = bpair(i+1, 2) - bpair(i, 2) + 1;
    Seg = stretch(tempObj, targetL);
    
    y2 = [former; Seg; latter];
    bpair(i+1:size(bpair, 1), 2) = bpair(i+1:size(bpair, 1), 2) - sourceL + targetL;
end

wObj2.signal = y2;
clear y2;

audiowrite('input/2nd_aligned_trim.wav', wObj2.signal, wObj2.fs);