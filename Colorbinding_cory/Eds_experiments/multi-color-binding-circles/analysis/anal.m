clear all
close all

line = 2;
filename = 'mbind-300t_100ms_16items_DOTS_1.txt';
filename = sprintf('../data/%s', filename);
f = fopen(filename);
for i = [1:line-1]
    discard = fgetl(f);
end    
    
% columns!
%  1    cue-length
%  2    ms-precue
%  3    resp-v-hv
%  4    ms-st-cue
%  5    nitems
%  6    resp-h-pos
%  7    resp-v-pos
%  8    ms-stimon
%  9    resp-h-hv
% 10    cue-loc-int
% 11    cue=loc-x
% 12    cue-loc-y
% 13    radius
% 14    bars-or-spot
% 15    npractice
% 16    ntrials
z = textscan(f,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ', 'delimiter', ',');

% precue = [0 50 100]
figure();
for i = [1:3]
    subplot(2,3,i);
    hist(z{6}(z{2}==precue(i)))
    title(sprintf('%d-1',i))
    subplot(2,3,i+3);
    hist(z{7}(z{2}==precue(i)))
    title(sprintf('%d-2',i))
end