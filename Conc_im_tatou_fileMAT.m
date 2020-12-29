% This function is based to concatenate the .mat file of the watermarked images.
clear all;
close all;
clc;

% Reading the .mat files.
file = dir(fullfile('watermaked_im\','*.mat'));   
files = {file.name}';
for r=1:length(files)   % sort the files based on their names.
    extr{r} = strtok(files{r},'.');
    num(r) = str2num(extr{r});
end
order=sort(num);

for i=1:length(files)
    ordered_files{i}=strcat(num2str(order(i)),'.mat');
    a{i} = load(strcat('watermaked_im\',ordered_files{i}));
end

%Fusing the xhole .mat files.
for j=1:length(ordered_files)
    Ima_tatou{j}=a{j}.Ima_tatou;
    Ima_tatou{j} = Ima_tatou{j}(~cellfun('isempty',Ima_tatou{j})); % Call Built-in string
    Ima_tatou{j}=cell2mat(Ima_tatou{j});
end
save('watermaked_im\Les_Im_Tatouee.mat','Ima_tatou');
                                                 
