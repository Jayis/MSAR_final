addpath C:\Users\Harry\Documents\MATLAB\utility
addpath C:\Users\Harry\Documents\MATLAB\sap
addpath C:\Users\Harry\Documents\MATLAB\machineLearning

pos_toler = 0.00005;
m_toler = 0.01;


input1 = 'mix/Yours.wav';
input2 = 'mix/Soul_new_cut_cut.wav';

wObj1 = waveFile2obj(input1);
wObj2 = waveFile2obj(input2);

y1 = wObj1.signal;
y2 = wObj2.signal;

inList = {input1 input2};

bpair = getSongPair (inList);

%% cut head
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

%% sync segment 1-by-1
tempObj = wObj2;
pos_in = 0;
m_in = 0;
pos_con = 0;
m_con = 0;
for i = 1: size(bpair, 1)-1
    i
    pos_in = 0;
    m_in = 0;
    
    tempObj.signal = y2(bpair(i, 2): bpair(i+1,2),1);
    
    former = y2(1:bpair(i,2)-1,1);
    latter = y2(bpair(i+1,2)+1:length(y2),1);
    
    targetL = bpair(i+1, 1) - bpair(i, 1)+1;
    sourceL = bpair(i+1, 2) - bpair(i, 2) + 1;
    if targetL <= 0 || sourceL <=0
        break;
    end
    Seg = stretch(tempObj, targetL + 882);
    
    %% head & tail in-amplify
    %{
    t1 = linspace(-100,0,length(Seg));
    t2 = linspace(0,-5,length(Seg));
    portion1 = exp(t1);
    portion2 = exp(t2);
    portion1(:) = 1 - portion1(:);
    portion2(:) = 1 - portion2(:);
    
    Seg = Seg .* reshape(portion1, length(portion1),1);
    Seg = Seg .* reshape(portion2, length(portion2),1);
    %}
    
    %% blend
    if i ~= 1
        % find continuous
        %{
        for j = 1: length(buff)
            if abs(buff(j) - Seg(j)) < pos_toler
                pos_in = 1;
                if j == 1
                    m_buff = buff(1) - former(length(former));
                    m_Seg = Seg(1) - former(length(former));
                else
                    m_buff = buff(j) - buff(j-1);
                    m_Seg = Seg(j) - Seg(j-1);
                end
                if abs(m_buff-m_Seg) < m_toler
                    p_conti = j;
                    m_in = 1;
                    break;
                end
            end
        end
        if pos_in == 1
            pos_con = pos_con+1;
        end
        if m_in == 1
            m_con = m_con + 1;
        end
        %}

            % linear    
            
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
            %{
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
            % exponential
            %{
        t1 = linspace(-5,0,length(buff));
        t2 = linspace(0,-5,length(buff));
        portion1 = exp(t1);
        portion2 = exp(t2);
        portion1(:) = 1 - portion1(:);
        portion2(:) = 1 - portion2(:);
        for j = 1: length(buff)
            Seg(j) = portion2(j)*Seg(j) + portion1(j)*buff(j);
        end
            %}
        
    end
        
    y2 = [former; Seg(1: targetL); latter];
    buff = Seg(targetL: length(Seg));
    bpair(i+1:size(bpair, 1), 2) = bpair(i+1:size(bpair, 1), 2) - sourceL + targetL;
    
end

gg = pos_con/size(bpair, 1)
ff = m_con/pos_con

wObj2.signal = y2;
clear y2;

audiowrite('mix/Soul_nnnnew_cut.wav', wObj2.signal, wObj2.fs);