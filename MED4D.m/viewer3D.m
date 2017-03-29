function a = viewer3D(I,omega,m,varargin)

global slice range
if nargin == 0,
  load('matlab');
end;

if ~exist('omega,','var'),    omega = []; end;
if ~exist('dataname,','var'), dataname = 'data'; end;

if isempty(omega),
  omega = reshape([zeros(1,3);m],1,[])
end;

h    = (omega(2:2:end)-omega(1:2:end))./m;
xi   = @(i) (omega(2*i-1)+h(i)/2:h(i):omega(2*i)-h(i)/2)';
xg   = {xi(1),xi(2),xi(3)};
md   = {1:m(1),1:m(2),1:m(3)};
xl   = {'x1','x2','x3'}
xyz  = '-xyz';

T = 60*reshape(I,m);
range = {1:m(1),1:m(2),1:m(3)};

switch xyz,
  case 'xyz'
    K = [1,2,3]
  case '-xyz'
    K = [1,2,3]
    xg{1} = flipdim(xg{1},1);
    md{1} = flipdim(md{1},1);
    T = flip(T,1);
  case 'yxz'
    K = [2,1,3];
    
  otherwise,
    error('nyi')
end

T = permute(T,K);
xg = xg(K);
xl = xl(K);

range = range{K(end)}

% flip dimension
T = T;

fig = FAIRfigure(2); clf;
str = sprintf('%s is %d-by-%d-by-%d, view direction is %s',...
  dataname,m(1),m(2),m(3),xyz)
set(fig,'name',str,'NumberTitle','off')

slice = 5;
dh = image(xg{1},xg{2},T(:,:,slice))
th = title(sprintf('slice=%d from %d-to-%d',slice,range(1),range(end)))
xlabel(xl{1});
ylabel(xl{2});
axis xy image
feval('colormap',colormap);



display = @(k) set(dh,'CData',T(:,:,k));
annot   = @(k) set(th,'string',sprintf('slice=%d from %d-to-%d',k,range(1),range(end)));


set(fig,'KeyPressFcn',@(h_obj,evt) KeyPressFcn(evt.Key,display,annot));


function KeyPressFcn(key,display,annot)
    
global slice range

mod = @(x) max(min(range),min(max(range),x));

switch key
  case 'uparrow'
    slice = mod(slice+1);
  case 'downarrow'
    slice = mod(slice-1);
  case 'escape'
    close all
    return
end

display(slice);
annot(slice)

