clear all;
close all;
clc;

% Load the indices of the watermarked pixels.
load('Les_Clefs_finales.mat');
size_base_clef=size(Idx_finale);
for p=1:size_base_clef(2)
    len_location_pixels_tatouees=length(Idx_finale{p});
end

%Load the watermarked images.
load('Les_Im_Tatouee.mat');
for k=1:length(Ima_tatou)
    ima_tato{k}=Ima_tatou{k};   
end
 
% Reconstruct the estimated images.
c=2;
load('Les_Marks.mat');
for k=1:length(ima_tato)
    Image_Istimee{k}=ima_tato{k};
    dim_image=size(Image_Istimee{k});
    for i=c+1:dim_image(1)-c
        for j=c+1:dim_image(2)-c
                Somme_ligne{k}(i,j)=sum(ima_tato{k}(i-c:i+c,j));
                Somme_colonnes{k}(i,j)=sum(ima_tato{k}(i,j-c:j+c));
                Image_Istimee{k}(i,j)=(1/(4*c))*(Somme_ligne{k}(i,j)+...
                                      Somme_colonnes{k}(i,j)-2*ima_tato{k}(i,j));
        end
    end
end

%Compute the Deltats of the manipulated pixels using the estimmated pixels.
indice_clef=1;
for k=1:length(ima_tato)   
    Image_Istimee{k}=double(Image_Istimee{k});
    for n=1:len_location_pixels_tatouees
        del{k}(n)=ima_tato{k}(Idx_finale{indice_clef}(n))-Image_Istimee{k}(Idx_finale{indice_clef}(n));
    end
    deltat{k}=del{k};
    indice_clef=indice_clef+1;
end

%Compute the Deltat of each element of the binary stream + the two reference bits.
nb_repetition=20;
lenght_serie_binaire=len_location_pixels_tatouees/nb_repetition; % The binary stream lenght.
for k=1:length(ima_tato)
    DeltatS{k}=0;
    for r=1:lenght_serie_binaire
        DeltatS{k}(r)=0;   
        for L=0:(nb_repetition-1)
             DeltatS{k}(r)=DeltatS{k}(r)+deltat{k}(r+L*lenght_serie_binaire);
        end  
        DeltatS{k}(r)=DeltatS{k}(r)/nb_repetition;
    end
end

%The Delta_R0, Delta_R1, and Threshold computation.
for k=1:length(ima_tato)
    for i=1:1
        Delta_R0{k}=DeltatS{k}(i);
        Delta_R1{k}=DeltatS{k}(i+1);
    end
    Threshold{k}=(Delta_R0{k}+Delta_R1{k})/2;
end

% Watermark detection.
for k=1:length(ima_tato)
    for r=1:lenght_serie_binaire
       if DeltatS{k}(r)>Threshold{k}
          watermark{k}(r)=1;
       else
          watermark{k}(r)=0;
       end     
    end
end
    
% Save the detected watermak 
if exist('Les_Watermark.mat')
   save('Les_Watermark.mat','watermark','-append')
else
   save('Les_Watermark.mat','watermark')
end
