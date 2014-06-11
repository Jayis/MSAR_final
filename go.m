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
    y2 = [zeros(head,1); y2];
    bpair(:,2) = bpair(:,2) + head;
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
    Seg = stretch(tempObj, targetL + 882);
    
    % blend
    if i ~= 1
        % linear 
        %{
        t = linspace(0,1,length(buff));
        for j = 1: length(buff)
            Seg(j) = t(j) * Seg(j) + (1-t(j))*buff(j);
        end
        %}
        % i dont know & 1-order predict
        %{
        Seg(1) = buff(1);
        Seg(2) = buff(2);
         for j = 3: length(buff)
             t = linspace(0,1,length(buff));
             conf = (1 - abs(buff(j) - Seg(j)));
             Seg(j) = conf * (t(j) * Seg(j) + (1-t(j))*buff(j)) + (1-conf)*((1-t(j))*(2 * Seg(j-1) - Seg(j - 2))+t(j)*Seg(j));
         end
        %}
        % i dont know & 2-order predict & confidence
        
        Seg(1) = buff(1);
        Seg(2) = buff(2);
        Seg(3) = buff(3);
        t = linspace(0,1,length(buff));
         for j = 4: length(buff)             
             conf = (1 - abs(buff(j) - Seg(j)));
             Seg(j) = conf * (t(j) * Seg(j) + (1-t(j))*buff(j)) + (1-conf)*((1-t(j))*(3 * buff(j-1) - 3*buff(j - 2)+buff(j-3)) + t(j)*Seg(j));
         end
       %}
        % i dont know & 2-order predict
        %{
        Seg(1) = buff(1);
        Seg(2) = buff(2);
        Seg(3) = buff(3);
        t = linspace(0,1,length(buff));
         for j = 4: length(buff)
             Seg(j) = (1-t(j))*(3 * buff(j-1) - 3*buff(j - 2)+buff(j-3)) + t(j)*Seg(j);
         end
       %}
    end
    
    y2 = [former; Seg(1: targetL); latter];
    buff = Seg(targetL: length(Seg));
    bpair(i+1:size(bpair, 1), 2) = bpair(i+1:size(bpair, 1), 2) - sourceL + targetL;
end

wObj2.signal = y2;
clear y2;

audiowrite('input/2nd_aligned_882_new.wav', wObj2.signal, wObj2.fs);