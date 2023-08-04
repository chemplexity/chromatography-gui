%% Initialize data structure for known compounds
mass_spectra_test_data = struct(...
    'sample_name', ...
    'method_name', ...
    'compound_name', ...
    'compound_formula', ...
    'compound_inchikey', ...
    'compound_exact_mass', ...
    'compound_score', ...
    'retention_time', ...
    'mz', ...
    'intensity');

%% Load data file
file = 'Pure_water_extract.D';
data = ImportAgilent(file);

%% Data pre-processing (centroid, baseline removal)
data = PreprocessMassSpectraData(data);

%% Define 1st compound
index = 1;

% Sample info
mass_spectra_test_data(index).sample_name = data.sample.name;
mass_spectra_test_data(index).method_name = data.method.name;

% Sample data
retentionTime = 4.782;
mass_spectra_test_data(index).retention_time = retentionTime;
mass_spectra_test_data(index).mz = data.mz;
mass_spectra_test_data(index).intensity =...
    data.xic(GetTimeIndex(data.time,retentionTime), :);

% NIST DB info
mass_spectra_test_data(index).compound_name = 'Water';
mass_spectra_test_data(index).compound_formula = 'H2O';
mass_spectra_test_data(index).compound_inchikey = 'XLYOFNOQVPJJNP-UHFFFAOYSA-N';
mass_spectra_test_data(index).compound_exact_mass = 18.0105647;
mass_spectra_test_data(index).compound_score = 95.6;
% prob 91.6, Match 713, R.Match 716

%% Define 2nd compound
index = 2;

% Sample info
mass_spectra_test_data(index).sample_name = data.sample.name;
mass_spectra_test_data(index).method_name = data.method.name;

% Sample data
retentionTime = 8.978;
mass_spectra_test_data(index).retention_time = retentionTime;
mass_spectra_test_data(index).mz = data.mz;
mass_spectra_test_data(index).intensity = ...
    data.xic(GetTimeIndex(data.time,retentionTime), :);

% NIST DB info
mass_spectra_test_data(index).compound_name = 'Ethanol, 2-butoxy-';
mass_spectra_test_data(index).compound_formula = 'C6H14O2';
mass_spectra_test_data(index).compound_inchikey = 'POAOYUHQDCAZBD-UHFFFAOYSA-N';
mass_spectra_test_data(index).compound_exact_mass = 118.0993795;
mass_spectra_test_data(index).compound_score = 77.1;
% prob 77.1, Match 918, R.Match 938

%% Define 3rd compound
index = 3;

% Sample info
mass_spectra_test_data(index).sample_name = data.sample.name;
mass_spectra_test_data(index).method_name = data.method.name;

% Sample data
retentionTime = 9.922;
mass_spectra_test_data(index).retention_time = retentionTime;
mass_spectra_test_data(index).mz = data.mz;
mass_spectra_test_data(index).intensity = ...
    data.xic(GetTimeIndex(data.time,retentionTime), :);

% NIST DB info
mass_spectra_test_data(index).compound_name = '1-Hexanol, 2-ethyl-';
mass_spectra_test_data(index).compound_formula = 'C8H18O';
mass_spectra_test_data(index).compound_inchikey = 'YIWUKEYIRIRTPP-UHFFFAOYSA-N';
mass_spectra_test_data(index).compound_exact_mass = 130.135765;
mass_spectra_test_data(index).compound_score = 70.5;
% prob 70.5, Match 946, R.Match 951

%% Define 4th compound
index = 4;

% Sample info
mass_spectra_test_data(index).sample_name = data.sample.name;
mass_spectra_test_data(index).method_name = data.method.name;

% Sample data
retentionTime = 10.254;
mass_spectra_test_data(index).retention_time = retentionTime;
mass_spectra_test_data(index).mz = data.mz;
mass_spectra_test_data(index).intensity = ...
    data.xic(GetTimeIndex(data.time,retentionTime), :);

% NIST DB info
mass_spectra_test_data(index).compound_name = 'Benzaldehyde';
mass_spectra_test_data(index).compound_formula = 'C7H6O';
mass_spectra_test_data(index).compound_inchikey = 'HUMNYLRZRPPJDN-UHFFFAOYSA-N';
mass_spectra_test_data(index).compound_exact_mass = 106.041865;
mass_spectra_test_data(index).compound_score = 66.5;
% prob 66.5, Match 922, R.Match 932

%% Define 5th compound
index = 5;

% Sample info
mass_spectra_test_data(index).sample_name = data.sample.name;
mass_spectra_test_data(index).method_name = data.method.name;

% Sample data
retentionTime = 12.027;
mass_spectra_test_data(index).retention_time = retentionTime;
mass_spectra_test_data(index).mz = data.mz;
mass_spectra_test_data(index).intensity = ...
    data.xic(GetTimeIndex(data.time,retentionTime), :);

% NIST DB info
mass_spectra_test_data(index).compound_name = 'alpha-Terpineol';
mass_spectra_test_data(index).compound_formula = 'C10H18O';
mass_spectra_test_data(index).compound_inchikey = 'WUOACPNHFRMFPN-SECBINFHSA-N';
mass_spectra_test_data(index).compound_exact_mass = 154.135765;
mass_spectra_test_data(index).compound_score = 62.3;
% prob 62.3, Match 930, R.Match 936

%% Define 6th compound
index = 6;

% Sample info
mass_spectra_test_data(index).sample_name = data.sample.name;
mass_spectra_test_data(index).method_name = data.method.name;

% Sample data
retentionTime = 13.736;
mass_spectra_test_data(index).retention_time = retentionTime;
mass_spectra_test_data(index).mz = data.mz;
mass_spectra_test_data(index).intensity = ...
    data.xic(GetTimeIndex(data.time,retentionTime), :);

% NIST DB info
mass_spectra_test_data(index).compound_name = '2,2,4-Trimethyl-1,3-pentanediol diisobutyrate';
mass_spectra_test_data(index).compound_formula = 'C16H30O4';
mass_spectra_test_data(index).compound_inchikey = 'OMVSWZDEEGIJJI-UHFFFAOYSA-N';
mass_spectra_test_data(index).compound_exact_mass = 286.214409;
mass_spectra_test_data(index).compound_score = 87.0;
% prob 87.0, Match 872, R.Match 874

%% Define 7th compound
index = 7;

% Sample info
mass_spectra_test_data(index).sample_name = data.sample.name;
mass_spectra_test_data(index).method_name = data.method.name;

% Sample data
retentionTime = 8.266;
mass_spectra_test_data(index).retention_time = retentionTime;
mass_spectra_test_data(index).mz = data.mz;
mass_spectra_test_data(index).intensity = ...
    data.xic(GetTimeIndex(data.time,retentionTime), :);

% NIST DB info
mass_spectra_test_data(index).compound_name = '2-Propanol, 1-butoxy-';
mass_spectra_test_data(index).compound_formula = 'C7H16O2';
mass_spectra_test_data(index).compound_inchikey = 'RWNUSVWFHDHRCJ-UHFFFAOYSA-N';
mass_spectra_test_data(index).compound_exact_mass = 132.115029;
mass_spectra_test_data(index).compound_score = 91.9;
% prob 91.9, Match 916, R.Match 924

%% finds index of nearest time value in the array
function index = GetTimeIndex(timeArray, timeValue)  

[~,index] = min(abs(timeArray - timeValue));

end