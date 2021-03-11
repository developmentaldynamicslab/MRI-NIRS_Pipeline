function snirf = ReadSnirf(fnamefullpath)

% Create empty snirf object
snirf = SnirfClass();

% Load the SNIRF fields into empty snirf class object, one at a time 
snirf.LoadMetaDataTags(fnamefullpath);
snirf.LoadData(fnamefullpath);
snirf.LoadProbe(fnamefullpath);
snirf.LoadStim(fnamefullpath);
snirf.LoadAux(fnamefullpath);


