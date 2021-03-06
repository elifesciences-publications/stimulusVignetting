%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute frequency responses of "steerable pyramid filters"

figure(1);
colormap gray(128);

dims = [64 64];
numLevels = 5;
numOrientations = 4;
bandwidth = 1/2;
[freqResps,pind]=makeSteerFRs(dims,numLevels,numOrientations,bandwidth);

% Look at them:
displayImage(accessSteerBand(freqResps,pind,numOrientations,1,1));
viewBands(freqResps,pind,1/4);
viewBands(abs(freqResps),pind,1/4);

% Check Tiling:
tile=zeros(dims);
tile=tile+abs(pyrLow(freqResps,pind)).^2;
tile=tile+abs(pyrHi(freqResps,pind)).^2;
for lev = 1:numLevels
  for orientation = 1:numOrientations
    tile=tile+(abs(accessSteerBand(freqResps,pind,numOrientations,...
	                           lev,orientation))).^2;
  end
end
clf
imagesc(tile,[.999 1.001])
max(max(tile))
min(min(tile))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test code for buildSteerBands and reconSteerBands (no subsampling)

al = pgmRead('einstein.pgm');
im = al(32:159,64:191);
displayImage(im);
colormap gray(128)

numOrientations = 4;
bandwidth = 1;
dims=size(im);
numLevels = maxLevel(dims,bandwidth);
freqResps = makeSteerFRs(dims,numLevels,numOrientations,bandwidth);
[pyr,pind] = buildSteerBands(im,freqResps);
viewBands(abs(freqResps),pind,1/4);
viewBands(pyr,pind,1/4);
recon = reconSteerBands(pyr,freqResps,pind);
displayImage(recon);
mse(im,recon)

% Check means (all but lowpass band should be zero)
mean2(im)
mean2(pyrLow(pyr,pind))
mean2(pyrHi(pyr,pind))
for lev = 1:numLevels
  for orientation = 1:numOrientations
    mean2(accessSteerBand(pyr,pind,numOrientations,lev,orientation))
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quadrature pyramid

al = pgmRead('einstein.pgm');
im = al(32:159,64:191);
displayImage(im);
colormap gray(128)

numOrientations = 4;
bandwidth = 1;
dims=size(im);
numLevels = maxLevel(dims,bandwidth);

[freqRespsImag,freqRespsReal,pind]= ...
    makeQuadFRs(dims,numLevels,numOrientations,bandwidth);
viewBands(freqRespsImag,pind,1/4);
viewBands(freqRespsReal,pind,1/4);
[pyr,pind]=buildQuadBands(im,freqRespsImag,freqRespsReal);
displayImage(accessSteerBand(pyr,pind,numOrientations,1,1));
displayImage(pyrLow(pyr,pind));
displayImage(pyrHi(pyr,pind));
viewBands(pyr,pind,1/4);

% Reconstruct from the real part because that includes the low and high
% bands.
recon=reconSteerBands(real(pyr),freqRespsReal,pind);
displayImage(recon);
norm(im(:)-recon(:))

% Compute amplitude and phase, then convert back to real and 
% imaginary.
amp=abs(pyr);
viewBands(amp,pind,1/4);
phi=atan2(imag(pyr),real(pyr));
viewBands(phi,pind,1/4);
newpyr=amp.*cos(phi) + i*amp.*sin(phi);
mse(pyr,newpyr)
viewBands(newpyr,pind,1/4);

% Check Tiling:
tile=zeros(dims);
tile=tile+abs(pyrLow(freqRespsReal,pind)).^2;
tile=tile+abs(pyrHi(freqRespsReal,pind)).^2;
for lev = 1:numLevels
  for orientation = 1:numOrientations
    tile=tile+...
	 0.5*(abs(accessSteerBand(freqRespsReal,pind,numOrientations,...
	                          lev,orientation))).^2+...
         0.5*(abs(accessSteerBand(freqRespsImag,pind,numOrientations,...
	                          lev,orientation))).^2;
  end
end
clf
imagesc(tile,[.999 1.001])
max(max(tile))
min(min(tile))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normalized energy pyramid

al = pgmRead('einstein.pgm');
im = al(32:159,64:191);

%im = 1+makeSine([64 64],4,0,1);
%im = 1+makeSine([64 64],4,0,0.1);

% Divide by mean and subtract 1 so that it is a "contrast"
% image.
im = im/mean2(im) - 1;

numOrientations = 4;
bandwidth = 1;
dims=size(im);
numLevels = maxLevel(dims,bandwidth);
[freqRespsImag,freqRespsReal,pind]= ...
    makeQuadFRs(dims,numLevels,numOrientations,bandwidth);

[pyr,pind]=buildQuadBands(im,freqRespsImag,freqRespsReal);
nEnergies=normEnergies(pyr,pind,numOrientations,0.1);
max2(nEnergies)

% max possible response is 0.8
viewBands(nEnergies,pind,1/4,[0 0.8]);
viewBands(nEnergies,pind,1/4,[0 max2(nEnergies)]);
band=accessSteerBand(nEnergies,pind,numOrientations,1,1);
displayImage(band,[0 0.8]);
imStats(band);

% Threshold at 25% of max possible response - few responses are
% above this level.
thresh=nEnergies>0.2;
viewBands(thresh,pind,1/4,[0 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fun with local amp and local phase

al = pgmRead('einstein.pgm');
im1 = al(32:159,64:191);
rich = pgmRead('feynman.pgm');
im2 = rich(32:159,64:191);
displayImage(im1);
displayImage(im2);

dims=size(im1);
numOrientations = 4;
bandwidth = 1;
numLevels = maxLevel(dims,bandwidth);
[freqRespsImag,freqRespsReal,pind]= ...
    makeQuadFRs(dims,numLevels,numOrientations,bandwidth);

% Switch local phase and amplitude of two images
[pyr1,pind]=buildQuadBands(im1,freqRespsImag,freqRespsReal);
amp1=abs(pyr1);
phi1=atan2(imag(pyr1),real(pyr1));
[pyr2,pind]=buildQuadBands(im2,freqRespsImag,freqRespsReal);
amp2=abs(pyr2);
phi2=atan2(imag(pyr2),real(pyr2));
newpyr1=amp1.*cos(phi2) + i*amp1.*sin(phi2);
newpyr2=amp2.*cos(phi1) + i*amp2.*sin(phi1);
recon1=reconSteerBands(real(newpyr1),freqRespsReal,pind);
recon2=reconSteerBands(real(newpyr2),freqRespsReal,pind);
displayImage(recon1);
displayImage(recon2);

% Randomize local phase
[pyr,pind]=buildQuadBands(im1,freqRespsImag,freqRespsReal);
amp=abs(pyr);
phi=atan2(imag(pyr),real(pyr));
phiRand=2*pi*rand(size(phi)) - pi;
newpyr=amp.*cos(phiRand) + i*amp.*sin(phiRand);
viewBands(newpyr,pind,1/4);
recon=reconSteerBands(real(newpyr),freqRespsReal,pind);
displayImage(recon);

% Randomize local amplitude.
% Could do much better by choosing the amplitudes to have about
% the right histogram shape (instead of uniform) and to have
% the variance decrease with scale.
ampRand=rand(size(amp));
newpyr=ampRand.*cos(phi) + i*ampRand.*sin(phi);
viewBands(newpyr,pind,1/4);
recon=reconSteerBands(real(newpyr),freqRespsReal,pind);
displayImage(recon);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change histogram of one band, reconstruct, rebuild.  What
% happens to the histogram?

al = pgmRead('einstein.pgm');
im = al(32:159,64:191);
numOrientations = 4;
bandwidth = 1;
dims=size(im);
numLevels = maxLevel(dims,bandwidth);
freqResps = makeSteerFRs(dims,numLevels,numOrientations,bandwidth);
[pyr,pind] = buildSteerBands(im,freqResps);

level=3;
orientation=1;
displayImage(accessSteerBand(pyr,pind,numOrientations,level,orientation));
b=(level-1)*numOrientations+(orientation+1)+1;
indices=pyrBandIndices(pind,b);
hist(pyr(indices),[-40:2:40]);

pyr1=pyr;
foo=100*(rand(size(pyr(indices)))-0.5);
pyr1(indices)=histMatch(pyr(indices),foo);
recon=reconSteerBands(pyr1,freqResps,pind);
displayImage(recon);
pyr2=buildSteerBands(recon,freqResps);
subplot(2,1,1);
hist(pyr1(indices),[-50:2:50]);
subplot(2,1,2);
hist(pyr2(indices),[-50:2:50]);
var2(pyr1(indices))
var2(pyr2(indices))

% Look at the effect on the other subbands:
level=2;
orientation=2;
b=(level-1)*numOrientations+(orientation+1)+1;
indices=pyrBandIndices(pind,b);
subplot(2,1,1);
hist(pyr1(indices),[-50:2:50]);
subplot(2,1,2);
hist(pyr2(indices),[-50:2:50]);
var2(pyr1(indices))
var2(pyr2(indices))


