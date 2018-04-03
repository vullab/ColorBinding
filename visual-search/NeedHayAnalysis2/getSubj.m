%% Edit subject list so can put onto php
fpath=cd;
fname=fullfile('fullSubj1');
datafile=fopen(fullfile(fpath,strcat(fname,'.txt')));
data =textscan(datafile,'%s' );

f = fopen('fullSubjMod1.txt', 'w');
for i=1:length(data{1})
    fprintf(f, strcat('"',data{1}{i},'",'));
end
fclose(f)