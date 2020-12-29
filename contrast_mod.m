function [r] = contrast_mod(I,n)



r=imadjust(uint8(I),[0 n],[0 1]); % n between 0.1 and 0.9
%figure

%imshow(uint8(r));



end