function scrollView(img,omega,m,direction,varargin)
% 
%
% scrollView(img,omega,m,direction,varargin)
% ------------------------------------------------------------------------- 
% Viewer for 3D and 4D data. Use ArrowUp, ArrowDown to navigate within the
% volume, ArrowLeft and ArrowRight to navigate between different timepoints
% and escape to close figures.
%
%   INPUT:
%   img        - 3D or 3D+time array.
%   omega      - spacial domain of img;
%                if omega=[], omega will be set up from m;
%   m          - usually m = size(img(:,:,:,1))
%   direction  - direction to scroll
%                1 - Scroll through img(i,:,:)
%                2 - Scroll through img(:,i,:)
%                3 - Scroll through img(:,:,i)
%   
%   VARARGIN:
%   mask       - mask to be simultaneously displayed with img. If img is a 
%                4D array, the mask will be displayed together with the 
%                first timepoint
%   scale      - How to scale the image?
%                 - 'slice', scale each slice individually
%                 - 'off', (DEFAULT) no scaling
%                 - 'volume', scaling to [0,255]
%   name       - name of figure
%   fig        - number of figure. Default: new figure
%   colormap   - colormap, default: 'gray'
%   quant      - cut-off abs(img) at a given quantile
%   quantmask  - cut-off abs(img) at a given quantile and visualizes the 
%                modified points in a mask (works only for 3D-volumes).
%        clims - color limits for scaling.
% ------------------------------------------------------------------------- 

% display help if no input is given
if nargin==0
    help(mfilename);
    runMinimalExample;
    return;
end

mask      = [];
scale     = 'off';
colormap  = 'gray';
fig       = [];
name      = [];
quant     = [];
quantmask = [];

% overwrites default variables
for j = 1:2:length(varargin)
  eval([varargin{j},'=varargin{',int2str(j+1),'};']);
end

%assert
assert(mod(numel(img),prod(m))==0,                 'img needs to have n*k elements (n = prod(m), k = #timepoints).')
assert((isempty(name))||ischar(name),              '''name'' needs to be string.')
assert(ischar(colormap),                           '''colormap'' needs to be string.')
assert(nargin >= 3,                                'Not enough input arguments')
assert((numel(m)>=3)&&(numel(m)<=4),               'Only 3D or 4D volumes supported')
assert((numel(m)==numel(omega)/2)||isempty(omega), 'Mismatch in numel(m) and numel(omega)/2')

%if no omega is given: setup own omega
if isempty(omega)
    omega = zeros(1,2*numel(m));
    omega(1:2:end-1) = 1/2;
    omega(2:2:end) = m+1/2;
end

%prepare img and setup main variables
k    = numel(img)/prod(m);
img  = reshape(double(img),[m,k]);
h    = (omega(2:2:end)-omega(1:2:end))./m;
xi   = @(i) (omega(2*i-1)+h(i)/2:h(i):omega(2*i)-h(i)/2)';

%create new figure if no fig is specified
if isempty(fig) 
    fig = gcf; 
    h   = gcf;
else
    h = figure(fig); 
end

%if no direction is given, set direction=3;
if ~exist('direction','var')
    direction = 3;
    warning('No direction specified: Set direction to 3')
end

if not(isnumeric(fig)),
  fig = fig.Number
end;
%prepare name
if ~isempty(name)
    name = sprintf('ScrollView [%i] - %s',fig,name);
else
    name = sprintf('ScrollView [%i]',fig);
end

%quantile normalization with mask
if ~isempty(quantmask)
    assert(size(img,4)==1, 'quantmask option works only for 3D-Volumes.')
    qImg  = quantile(abs(img(:)),quantmask);
    
    idxPlus  = img>qImg;
    idxMinus = img<-qImg;
    mask     = idxPlus + idxMinus;
    
    img(idxPlus)  = qImg;
    img(idxMinus) = -qImg;
    
    name = [name,': Quantile Normalization ON.'];
end

if exist('clims','var')
    scale = 'clims';
end


%quantile normalization without mask
if ~isempty(quant)
    qImg  = quantile(abs(img(:)),quant);
    
    idxPlus  = img>qImg;
    idxMinus = img<-qImg;
    
    img(idxPlus)  = qImg;
    img(idxMinus) = -qImg;
    
    name  = [name,': Quantile Normalization ON.'];
end

%if a mask is given: Deal with it!
if ~isempty(mask)
    
    %assert
    assert(isequal(size(mask),m),'It needs to hold that size(mask) = m.')
    assert(~any(mask(:)<0),'The mask needs to be non-negative')
    
    %get masked image and setup scale
    img   = prepareMask(img,mask);
    scale = 'mask';
    k     = 1;
end



%prepare img according to the given direction
switch direction
    case 1
        x1 = xi(2); x2 = xi(3);
        label1 = 'y'; label2 = 'z';
        
    case 2
        img = permute(img,[2,1,3,4]);
        x1 = xi(1); x2 = xi(3);  
        label1 = 'x'; label2 = 'z';
    case 3
        img = permute(img,[3,1,2,4]);
        x1 = xi(1); x2 = xi(2);          
        label1 = 'x'; label2 = 'y';
        
    otherwise
        error('Direction not (yet) supported')
end



%setup the scaling
switch scale
    case 'volume'
        img     = img-min(img(:));
        img     = 255*img./max(img(:));
        clims = [0,255];
        display = @(k,l) imagesc(x1,x2,squeeze(img(k,:,:,l))',clims);
        
    case {'slice','slices'}
        display = @(k,l) imagesc(x1,x2,squeeze(img(k,:,:,l))');
        
    case 'off'
        clims = [min(img(:)),max(img(:))];
        display = @(k,l) imagesc(x1,x2,squeeze(img(k,:,:,l))',clims);
        
    case 'mask'
        display = @(k,l) imagesc(x1,x2,permute(squeeze(img(k,:,:,:)),[2,1,3])); 
        
    case 'clims'
        display = @(k,l) imagesc(x1,x2,squeeze(img(k,:,:,l))',clims);

    otherwise
        error('Scaling not (yet) supported');

end




%setup figure
set(h,'name',name,'NumberTitle','off')
display(1,1)
title('Slice: 1, Dataset: 1')
xlabel(label1);
ylabel(label2);
axis xy image
feval('colormap',colormap);

set(h,'KeyPressFcn',@(h_obj,evt) KeyPressFcn(evt.Key,display,m(direction),k,label1,label2));




end




function maskA = prepareMask(img,mask)

    
    if ndims(img) == 4
        img = img(:,:,:,1);
        disp('Displaying mask for first timepoint.')
    end
    
    %create a color array
    img     = (img-min(img(:)))./(max(img(:)) - min(img(:)));
    maskA = repmat(img,[1,1,1,3]);
    
    %setup indices for red channel of mask and other channels of mask
    idxRed   = zeros([size(mask),3]);
    idxGreen = zeros([size(mask),3]);
    idxBlue  = zeros([size(mask),3]);
    
	idxRed(:,:,:,1)   = (mask~=0);
    idxGreen(:,:,:,2) = (mask~=0);
    idxBlue(:,:,:,3)  = (mask~=0);
    
    %setup the mask
    maskA(idxRed~=0)   = mask(mask~=0);
    maskA(idxGreen~=0) = 0;
    maskA(idxBlue~=0)  = 0;


end







function KeyPressFcn(key,display,mdir,k,label1,label2)
    
    persistent j l;
    
    
    if isempty(j) || isempty(l)
        j = 1;
        l = 1;
    end
    
    
    switch key
        case 'uparrow'
            j = j+1;
        case 'downarrow'
            j = j-1;
        case 'leftarrow'
            l = l-1;
        case 'rightarrow'
            l = l+1;
        case 'escape'
            clear k l
            close all
            return
    end
    
    if j <= 1
        j = 1;
    elseif j >= mdir;
        j = mdir;
    end
    
    if l >= k
        l = k;
    elseif l <= 1
        l = 1;
    end
    
   
    display(j,l);
    title(['Slice: ',num2str(j),',   Dataset:',num2str(l)])
    xlabel(label1)
    ylabel(label2)
    axis xy image

end

function runMinimalExample
error('nyi');
end