Dnii =load_nii('/Volumes/mic/Daten/DCEMRI-Bergen/Bergen_2011/NYRE_111101_AS/left-GD.nii.gz');
Dmat = load('/Volumes/mic/Daten/DCEMRI-Bergen/Bergen_2011/NYRE_111101_AS/left-GD.mat');
Anii = Dnii.img;
Amat = Dmat.im;


for j = 3:3
  j
  for k=1:size(Amat,4)
    k
    Snii = Anii(:,:,j,k);
    Smat = Amat(:,:,j,k);
    
    figure(1);
    subplot(1,3,1);
    imagesc(Snii)
    title(sprintf('k=%d',k))
    xlabel(sprintf('j=%d',j))
    
    subplot(1,3,2);
    imagesc(Smat)
    subplot(1,3,3);
    imagesc(Snii-5.5*Smat)
    
    pause(1/2)
  end
end
