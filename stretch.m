function [ output_y ] = stretch ( input_y, target_length)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

input = length(input_y);
target = target_length;

opt=pitchShift('defaultOpt');
opt.method='wsola';
opt.pitchShiftAmount = log2(target/input) * 12;
input_y =pitchShift(input_y, opt, 1);
output_y = resample(input_y.signal, target, input);

end

