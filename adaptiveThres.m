function [o] = adaptiveThres(a,W,noShow);
%Adaptive thresholding is performed by segmenting image a
%Honors Project 2001~2002
%wuzhili 99050056
%comp sci HKBU
%last update 19/April/2002

[w,h] = size(a);% size de l'image a
o = zeros(w,h);

%seperate it to W block
%step to w with step length W

for i=1:W:w % W nombre de block
for j=1:W:h
mean_thres = 0;

%white is ridge -> large

if i+W-1 <= w & j+W-1 <= h
   	mean_thres = mean2(a(i:i+W-1,j:j+W-1));
   	%threshold value is choosed ( c'est la moyenne de niveau de gris)
      mean_thres = 0.8*mean_thres;% transformer 8 bit au gris image ? 1 bit binaire
      %before binarization
      %ridges are black, small intensity value -> 1 (white ridge)
      %the background and valleys are white, large intensity value -> 0(black)
      o(i:i+W-1,j:j+W-1) = a(i:i+W-1,j:j+W-1) < mean_thres;
end;
   
end;
end;


% if nargin == 2
% imagesc(o);
% colormap(gray);% afficher l'image en noir et blanc
% end;
