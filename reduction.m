%This function is based to extract the face features using the OLPP metric.
function newfea_Tr = reduction()

%Loading the face images and their Indices.
load('ORL_64x64.mat');
len_base=size(fea);

load('Indices.mat');
len_Ind=size(cell2mat(Idx));
 
%Data
fea_Train = fea(cell2mat(Idx),:);  
gnd_Train = gnd(cell2mat(Idx)); 

options = [];  
options.NeighborMode = 'Supervised';  
options.WeightMode = 'Cosine';  
options.gnd = gnd_Train;  
W = constructW(fea_Train,options);   
options.Regu = 0; 
options.PCARatio = 1; 
bSuccess = 0;

while ~bSuccess 
      [eigvector, eigvalue, bSuccess] = OLPP(W, options, fea_Train);  %Run OLPP on the training data  
end  

for k=1:size(eigvector,2)
    newfea_Tr = fea_Train*eigvector(:,1:k) ;
end

