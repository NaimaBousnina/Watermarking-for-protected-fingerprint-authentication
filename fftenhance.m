function [final]=fftenhance(image,f)
%Honors Project 2001~2002
%wuzhili 99050056
%comp sci HKBU
%last update 19/April/2002

I = 255-double(image);

[w,h] = size(I);
%out = I;

w1=floor(w/32)*32;
h1=floor(h/32)*32;

inner = zeros(w1,h1);
f=0;
for i=1:32:w1
   for j=1:32:h1
      a=i+31;
      b=j+31;
      F=fft2( I(i:a,j:b) );
      factor=abs(F).^f;% f est la constante donnée par l'utilisateur k dans le rapport
      block = abs(ifft2(F.*factor));
      
      larv=max(block(:));% retoure la taille de block 1024
      if larv==0
         larv=1;
      end;
      
      block= block./larv;
      inner(i:a,j:b) = block;
   end;
end;

%out(1:w1,1:h1)=inner*255;
final=inner*255;

%d=max(out(:)); %Find max pixel value in C.
%c=min(out(:));
%figure
%imshow(out,[c d]);

final=histeq(uint8(final));
%final=adaptiveThres2(final,32,0);

%imagesc(final);
%colormap(gray);
