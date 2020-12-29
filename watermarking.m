clear all;
close all;
clc;

%%%% Step 1: Watermark preparation %%%%

%Face features extraction using The OLPP metric.
newfea_Tr=reduction();

%Binary conversion of face features.
for l=1:size(newfea_Tr,1)
    serie_binaire{l}=0;
    for n=1:size(newfea_Tr(1,:),2)
        serie_binaire_partial{n}=float2bin(newfea_Tr(l,n));
        serie_binaire{l}=strcat(serie_binaire{l},serie_binaire_partial{n});
    end
    serie_binaire{l}=strcat('01',serie_binaire{l}); % Add the two reference bits 0 and 1.
    long_Each_wat_ima=size(serie_binaire{l}); 
end

% Save the banary stream (watermark)
if exist('Les_Series_bini.mat')
   save('Les_Series_bini.mat','serie_binaire','-append');
else
   save('Les_Series_bini.mat','serie_binaire');
end

%%%% Step 2: Minutia area localization %%%%    

% Load fingerprint images.
 p=1;
for finger_no=1:40
    for k=1:8
        fingers2{finger_no,k} = imread(['Db2_a\' int2str(finger_no),'_',int2str(k),'.tif']);
        Image_orig{p}=fingers2{finger_no,k};
        SI= size(Image_orig{p});
        p=p+1; 
    end
end
len_database=length(Image_orig);

%Minutiae points cordinates.
load('Or_Minutias');
Tai_real_end=size(Minutia);
  
%The number of minutiaes for each image.
for m=1:Tai_real_end(2)
    minu_dim=size(Minutia{1,m});
    nb_minutiae(m)=minu_dim(1);
end
 
%Generation of matrices of ones with dimensions 560*296
for k=1:len_database   
    Mark{k}=ones(560,296);
    size_Mark=size(Mark{k});
end
  
%Mark with 0 the locations of minutiae and their entourage 7 * 7 in the images.
for k=1:len_database
    for i=1:SI(1)
        for j=1:SI(2)
            for L=1:nb_minutiae(k)
                if [i,j]==Minutia{1,k}(L,[1,2])
                   for s=i-3:i+3
                       for l=j-3:j+3
                           Mark{k}(s,l)=0;
                       end
                   end
                end
            end
        end
    end
end

% random key of dimension 560 * 296 generation for each person (this key is used during the test phase)
for p=1:len_database/8  
    clef_generee{p}=rand(1,560*296);
    len_clef=size(clef_generee{p});
    [random_key_srt{p},Idx{p}]=sort(abs(clef_generee{p}),'descend');
end
  
%Store tha generated keys
if exist('clefs.mat')
   save('clefs.mat','Idx','-append')
else
   save('clefs.mat','Idx')
end

%Random key of limited size generationfor each image (this key will be used during the watermark extraction phase).
 nb_repetition_watermark=20; % The number of time the watermark is embedded.
 Len_clef_reduit=long_Each_wat_ima*nb_repetition_watermark;
 indice_clef=1;
 indice_pers=1;
 fin=8;
 k=1;
while k<=len_database
      Mark{k} = reshape(Mark{k},1,[]);
     if k<=fin
        i=1;
        r=1;
        while i<=len_clef(2)
              if r<=Len_clef_reduit(2)
                 j=Idx{indice_clef}(i); 
                 if Mark{k}(j)==1
                    Mark{k}(j)=2;
                    Idx_finale{k}(r)=j;
                    r=r+1;
                    i=i+1;
                 else
                    i=i+1;
                 end
              else
                 i=len_clef(2)+1;
              end
        end
        k=k+1;
    else
        fin=fin+8;
        indice_clef=indice_clef+1;
     end
end 
 
% Save the Marks
if exist('Les_Marks.mat')
   save('Les_Marks.mat','Mark','-append');
else
   save('Les_Marks.mat','Mark');
 end 
%Save the indices of the pixels that will be manipulated.
if exist('Les_Clefs_finales.mat')
   save('Les_Clefs_finales.mat','Idx_finale','-append');
else
   save('Les_Clefs_finales.mat','Idx_finale');
end 

%%%% Step 3: Watermark embedding %%%% 

q=0.05;
A=100;
B=1000;

%Standard deviation computation fore each pixel.
nhood= [1 0 0 0 1
        0 1 0 1 0
        0 0 1 0 0
        0 1 0 1 0
        1 0 0 0 1;];
    
for k=1:len_database
   Ecar_type{k} = stdfilt(Image_orig{k},nhood);
 end

%Maghitude gradient computation
 for k=1:len_database
     [Gmag,Gdir] = imgradient(Image_orig{k});
     grad_img{k}=Gmag;
 end

indice_personne=1; % indix to verify that the eight images belong to the same person.
fin=8;
k=1;
indice_clef=0;
nn=0;

while k<=len_database
      Image_orig{k}=double(Image_orig{k});
      Image_orig{k} = reshape(Image_orig{k},1,[]);
      Ecar_type{k} = reshape(Ecar_type{k},1,[]);
      grad_img{k} = reshape(grad_img{k},1,[]);
      if indice_personne<=fin
         indice_clef=indice_clef+1;
         nn=nn+1;
         Ima_tatou{k}=Image_orig{k};
         l=1;
         i=1;
         j=0;
         while i<= Len_clef_reduit(2)
               if l<=long_Each_wat_ima(2)
                  j=Idx_finale{indice_clef}(i);
                  Ima_tatou{k}(j)=Image_orig{k}(j)+(2*str2double(serie_binaire{k}(l))-1)*Image_orig{k}(j)*q*...
                                 (1+(1/A)*Ecar_type{k}(j))*(1+(1/B)*grad_img{k}(j));
                  l=l+1;
                  i=i+1; 
               else
                  l=1;
               end
         end
         Ima_tatou{k} = reshape(Ima_tatou{k},SI(1),SI(2));
         Image_orig{k} = reshape(Image_orig{k},SI(1),SI(2));
         
         %Save the watermarked images.
         if exist(strcat('watermaked_im\',sprintf('%01d.mat',nn)))
            save(strcat('watermaked_im\',sprintf('%01d.mat',nn)),'Ima_tatou','-append');
         else
            save(strcat('watermaked_im\',sprintf('%01d.mat',nn)),'Ima_tatou');
         end
         indice_personne=indice_personne+1; 
         k=k+1;
       else
         indice_personne=1;
       end   
end
