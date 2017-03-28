function G = rgb2gray4D(X);

m = size(X);
if not(length(m) == 4),
  error('1')
end;

if not(m(4) == 3),
  error('1')
end;

G = 0.299 * X(:,:,:,1) + 0.587 * X(:,:,:,2) + 0.114 * X(:,:,:,3);
%