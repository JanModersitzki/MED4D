function a = viewer3D(I,omega,m,varargin)


if nargin == 0,
  load('matlab');
end;

xyz      = [];
colormap = [];
scale    = [];
slice    = [];
movie    = [];

if ~exist('omega,','var'),    omega    = [];          end;
if ~exist('dataname,','var'), dataname = 'data';      end;
if isempty(xyz),              xyz      = 'xyz';       end;
if isempty(colormap),         colormap = 'bone';      end;
if isempty(scale),            scale    = '0:max(Tk)'; end;
if isempty(movie),            movie    = 'none';      end;


if isempty(omega),
  omega = reshape([zeros(1,3);m],1,[])
end;

h    = (omega(2:2:end)-omega(1:2:end))./m;
xi   = @(i) (omega(2*i-1)+h(i)/2:h(i):omega(2*i)-h(i)/2)';

xg   = {xi(1),xi(2),xi(3)};      grids  = xg;
xl   = {'x1','x2','x3'};         labels = xl;
md   = {1:m(1),1:m(2),1:m(3)};   dims   = md;   range = md{end};

T0   = reshape(I,m);
T    = [];

xyzOptions = {
  'xyz'
  'yxz'
  'xzy'
  };
xyzValue = find(strcmp(xyz,xyzOptions));

colormapOptions = {
  'hsv'
  'bone'
  'gray'
  };
colormapValue = find(strcmp(colormap,colormapOptions));

scaleOptions = {
  '0:255'
  '0:1'
  '0:max(T)'
  '0:max(Tk)'
  'min:max = ?'
  };
scaleValue = find(strcmp(scale,scaleOptions));

movieOptions = {
  'none'
  'palindrome'
  };
movieValue = find(strcmp(movie,movieOptions));

sldText = @(slice,range) ...
  sprintf('slice: %d from %d:%d',slice,range(1),range(end));

Tpos = @(p) [0.80 1.00-(p*0.1) 0.18 0.04];
Vpos = @(p) [0.80 0.96-(p*0.1) 0.18 0.04];
Tcontrol = @(p,str) uicontrol(...
  'Style','text','fontsize',14,...
  'Units','normalized','Position',Tpos(p),...
  'String',str);

Pcontrol = @(p,options,value,callback) uicontrol(...
  'Style','popup',...
  'String',options,'Value',value,'fontsize',14,...
  'Units','normalized','Position',Vpos(p),...
  'Callback',callback);

range
slice
% -----------------------------------------------------------------------------
% prepare figure
fig = FAIRfigure(2); clf;
str = sprintf('%s is %d-by-%d-by-%d, view direction is ---',...
  dataname,m(1),m(2),m(3))
set(fig,'name',str,'NumberTitle','off')
s1 = subplot('position',[0.05,0.15,0.7,0.8]);
dh = 0;

% xyz direction
tXYZ    = Tcontrol(1,'view direction');
hXYZ    = Pcontrol(1,xyzOptions,xyzValue,@setXYZ);
% colormap
tMap    = Tcontrol(2,'colormap');
hMap    = Pcontrol(2,colormapOptions,colormapValue,@setColormap);
% scale
tScale  = Tcontrol(3,'scales');
hScale  = Pcontrol(3,scaleOptions,scaleValue,@setScale);
% movie
tMovie  = Tcontrol(4,'movie');
hMovie  = Pcontrol(4,movieOptions,movieValue,@setMovie);

tSLD = Tcontrol(7,sldText(slice,range));
hSLD = uicontrol(...
  'Style','slider',...
  'Min',1,'Max',2,'Value',slice,...
  'SliderStep', [1 , 1],...
  'Units','normalized', 'Position',Vpos(7),...
  'Callback', @setSlice);

btn = uicontrol(...
  'Style','pushbutton',...
  'String','quit','fontsize',14,...
  'Units','normalized','Position',Tpos(9),...
  'Callback',@doQuit);
% -----------------------------------------------------------------------------

setXYZ(hXYZ,[]);
return

  function setXYZ(source,event)

    switch xyzOptions{source.Value},
      case 'xyz',     K = [1,2,3];  flips = [0,0,0];
      case '-xyz',    K = [1,2,3];  flips = [1,0,0];
      case 'yxz',     K = [2,1,3];  flips = [0,0,0];
      otherwise,
        error('nyi');
    end;
    
    T      = permute(T0,K);
    grids  = xg(K);
    labels = xl(K);
    dims   = md(K);
    range  = md{end};
    
    for k = 1:length(flips),
      if flips(k),
        T          = flipdim(T,k);
        grids{k}   = flipdim(grids{k},1);
        labels{k}  = ['-',labels{k}];
        dims{k}    = flipdim(dims{k},2);
      end;
    end

    % deal slice
    slice = hSLD.Value;
    numSteps = max(range)-min(range);
    if isempty(slice),
      slice = floor(numSteps/2);
    end;
    slice = min(max(min(range),slice),max(range));
    
    set(hSLD,...
      'Min',min(range),...
      'Max',max(range),...
      'Value',slice,...
      'SliderStep', [1/numSteps , 5/numSteps]);
    set(tSLD,'string',sldText(slice,range));
    
    dh = image(grids{1},grids{2},T(:,:,slice));
    xlabel(labels{1});
    ylabel(labels{2});
    axis xy image

    setSlice(hSLD,[]);
    setColormap(hMap,[])
    setScale(hScale)
  end

  function setColormap(source,event)
    v = source.Value;
    feval('colormap',s1,colormapOptions{v});
  end;
  
  function setSlice(source,event)
    slice = source.Value;
    set(dh,'CData',T(:,:,slice));
    set(tSLD,'String',sldText(slice,range));
    setScale(hScale,[]);
  end

  function setScale(source,event)
    scale = scaleOptions{source.Value}
    switch scale
      case '0:max(T)',
        set(dh,'CDataMapping','scaled')
        set(s1,'CLim',[0,max(T(:))]);
      case '0:max(Tk)',
        set(dh,'CDataMapping','scaled')
        set(s1,'CLim',[0,max(reshape(T(:,:,hSLD.Value),[],1))]);
      case 'min:max = ?',
        fprintf('range(T) = %e-to%e\n',min(T(:)),max(T(:)));
        
        Cmin = input(' min = ?')
        Cmax = input('max = ?')
        set(dh,'CDataMapping','scaled')
        set(s1,'CLim',[Cmin,Cmax]);
        
      otherwise, error('nyi');
    end
  end

  function setMovie(source,event)
    v = source.Value
    
    switch movieOptions{v},
      case 'none',
      case 'palindrome',
        k = 0; dk = 1; 
        range = 1:size(T,3);
        while source.Value == 2,
          k = k + dk;
          if k>range(end), k = k-1; dk = -dk;  end;
          if k<range(1),   k = 1;   dk = -dk;  end;
          
          set(dh,'CData',T(:,:,k));
          set(tSLD,'String',sldText(k,range));
          set(hSLD,...
            'Min',min(range),...
            'Max',max(range),...
            'Value',k);

          pause(1/6);
        end;
      otherwise,
        error('nyi')
    end;
    
  end;

  function doQuit(source,event)
    if source.Value == 1
      close(fig);
    end;
  end;

end






