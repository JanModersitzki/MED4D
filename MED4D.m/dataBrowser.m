set(0,'DefaultAxesFontSize',30) 
dataSource = '/Volumes/mic/Daten/DCEMRI-Bergen/Bergen_2011';
dataFolder = {
  'quit'
  'NYRE_111101_AS'
  'NYRE_111101_MH'
  'NYRE_111101_MN'
  'NYRE_120131_RJH'
}

%opt = dataFolder{menu('Pick Data',dataFolder{:})};
opt = 'NYRE_111101_AS';


if strcmp(opt,'quit'), 
  return;
end;

folder = fullfile(dataSource,opt)

files = {
	'003_b1map_epi_se_60.nii.gz'
	'004_b1map_epi_se_120.nii.gz'
	'README.txt'
	'flip05.nii.gz'
	'flip08.nii.gz'
	'flip15.nii.gz'
	'flip25.nii.gz'
  
	'left-GD.mat'
	'left-GD.nii.gz'
	'left-aif-mask.nii.gz'
	'left-flip05-mcflirt.nii.gz'
	'left-flip05-reg-ngf1-mi0-fluid.nii.gz'
	'left-flip05.nii.gz'
	'left-flip08-mcflirt.nii.gz'
	'left-flip08-reg-ngf1-mi0-fluid.nii.gz'
	'left-flip08.nii.gz'
	'left-flip15-mcflirt.nii.gz'
	'left-flip15-reg-ngf1-mi0-fluid.nii.gz'
	'left-flip15.nii.gz'
	'left-flip25-mcflirt.nii.gz'
	'left-flip25-reg-ngf1-mi0-fluid.nii.gz'
	'left-flip25.nii.gz'
	'left-mask-background.nii.gz'
	'left-mask-cortex.nii.gz'
	'left-mcflirt-GD.mat'
	'left-mcflirt-GD.nii.gz'
	'left-mcflirt.nii.gz'
	'left-mcflirt_mean_reg.nii.gz'
	'left-reg-ngf0-mi1-fluid-GD.mat'
	'left-reg-ngf0-mi1-fluid-GD.nii.gz'
	'left-reg-ngf1-mi0-fluid-GD.mat'
	'left-reg-ngf1-mi0-fluid-GD.nii.gz'
	'left-reg-ngf1-mi0-fluid.nii.gz'
	'left-segm-background.nii.gz'
	'left-segm-cortex.nii.gz'
	'left-segm-kidney.nii.gz'
	'left.nii.gz'
	'perfusjon.nii.gz'
	'right-GD.mat'
	'right-GD.nii.gz'
	'right-aif-mask.nii.gz'
	'right-flip05-mcflirt.nii.gz'
	'right-flip05-reg-ngf1-mi0-fluid.nii.gz'
	'right-flip05.nii.gz'
	'right-flip08-mcflirt.nii.gz'
	'right-flip08-reg-ngf1-mi0-fluid.nii.gz'
	'right-flip08.nii.gz'
	'right-flip15-mcflirt.nii.gz'
	'right-flip15-reg-ngf1-mi0-fluid.nii.gz'
	'right-flip15.nii.gz'
	'right-flip25-mcflirt.nii.gz'
	'right-flip25-reg-ngf1-mi0-fluid.nii.gz'
	'right-flip25.nii.gz'
	'right-mask-background.nii.gz'
	'right-mask-cortex.nii.gz'
	'right-mcflirt-GD.mat'
	'right-mcflirt-GD.nii.gz'
	'right-mcflirt.nii.gz'
	'right-mcflirt_mean_reg.nii.gz'
	'right-reg-ngf0-mi1-fluid-GD.mat'
	'right-reg-ngf0-mi1-fluid-GD.nii.gz'
	'right-reg-ngf1-mi0-fluid-GD.mat'
	'right-reg-ngf1-mi0-fluid-GD.nii.gz'
	'right-reg-ngf1-mi0-fluid.nii.gz'
	'right-segm-background.nii.gz'
	'right-segm-cortex.nii.gz'
	'right-segm-kidney.nii.gz'
	'right.nii.gz'
	'timeline.txt'
	};

for k=25:27%:length(files)
  filename = fullfile(dataSource,opt,files{k});
  fprintf('%4d-of-%4d is %s\n',k, length(files),files{k})
  
  switch files{k},
    case {
        '003_b1map_epi_se_60.nii.gz'
        '004_b1map_epi_se_120.nii.gz'
        'flip05.nii.gz'
        'flip08.nii.gz'
        'flip15.nii.gz'
        'flip25.nii.gz'
        'left-aif-mask.nii.gz'
        'left-flip05-mcflirt.nii.gz'
        'left-flip05-reg-ngf1-mi0-fluid.nii.gz'
        'left-flip05.nii.gz'
        'left-flip08-mcflirt.nii.gz'
        'left-flip08-reg-ngf1-mi0-fluid.nii.gz'
        'left-flip08.nii.gz'
        'left-flip15-mcflirt.nii.gz'
        'left-flip15-reg-ngf1-mi0-fluid.nii.gz'
        'left-flip15.nii.gz'
        'left-flip25-mcflirt.nii.gz'
        'left-flip25-reg-ngf1-mi0-fluid.nii.gz'
        'left-flip25.nii.gz'
        'left-mask-background.nii.gz'
        'left-mask-cortex.nii.gz'
        'left-mcflirt-GD.mat'
        'left-mcflirt-GD.nii.gz'
        'left-mcflirt.nii.gz'
        'left-mcflirt_mean_reg.nii.gz'
        'left-reg-ngf0-mi1-fluid-GD.mat'
        'left-reg-ngf0-mi1-fluid-GD.nii.gz'
        'left-reg-ngf1-mi0-fluid-GD.mat'
        'left-reg-ngf1-mi0-fluid-GD.nii.gz'
        'left-reg-ngf1-mi0-fluid.nii.gz'
        'left-segm-background.nii.gz'
        'left-segm-cortex.nii.gz'
        'left-segm-kidney.nii.gz'
        'left.nii.gz'

        }
      
      fprintf('load_nii(''%s'')\n',filename);
      D = load_nii(filename);
      figure(k); clf;
      I = D.img;
      m = size(I)
      
      if length(m) == 4,
        m = m(1:3);
        I = rgb2gray4D(I);
      end;
      
      omega = reshape([zeros(1,3);m],1,[])
      imgmontage(I,omega,m);
      colormap(gray);
      title(filename,'interpreter','none')
      
    case {'left-GD.mat'}
      
    case {'left-GD.nii.gz'}
      fprintf('load_nii(''%s'')\n',filename);
      D = load_nii(filename);
      I = D.img;
      m = size(I)
      omega = reshape([zeros(1,3);m(1:3)],1,[])
      error('tbc')

      

    case 'README.txt'
      
    otherwise,
      error('17')
  end;
  
  %return
end;

