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
file = 'Porabond 200 - 400.D';
data = ImportAgilent(file);

%% Data pre-processing (centroid, baseline removal)
data = PreprocessMassSpectraData(data);

%% Define 1st compound
index = 1;

% Sample info
mass_spectra_test_data(index).sample_name = data.sample.name;
mass_spectra_test_data(index).method_name = data.method.name;

% Sample data
retentionTime = 41.549;
mass_spectra_test_data(index).retention_time = retentionTime;
mass_spectra_test_data(index).mz = data.mz;
mass_spectra_test_data(index).intensity =...
    data.xic(GetTimeIndex(data.time,retentionTime), :);

% NIST DB info
mass_spectra_test_data(index).compound_name = 'Carbon disulfide';
mass_spectra_test_data(index).compound_formula = 'CS2';
mass_spectra_test_data(index).compound_inchikey = 'QGJOPFRUJISHPQ-UHFFFAOYSA-N';
mass_spectra_test_data(index).compound_exact_mass = 75.944142;
mass_spectra_test_data(index).compound_score = 98.2;
% prob 98.2, Match 903, R.Match 939

%% Define 2nd compound
index = 2;

% Sample info
mass_spectra_test_data(index).sample_name = data.sample.name;
mass_spectra_test_data(index).method_name = data.method.name;

% Sample data
retentionTime = 29.2;
mass_spectra_test_data(index).retention_time = retentionTime;
mass_spectra_test_data(index).mz = data.mz;
mass_spectra_test_data(index).intensity = ...
    data.xic(GetTimeIndex(data.time,retentionTime), :);

% NIST DB info
mass_spectra_test_data(index).compound_name = 'Methanethiol';
mass_spectra_test_data(index).compound_formula = 'CH4S';
mass_spectra_test_data(index).compound_inchikey = 'LSDPWZHWYPCBBB-UHFFFAOYSA-N';
mass_spectra_test_data(index).compound_exact_mass = 48.0033712;
mass_spectra_test_data(index).compound_score = 98.4;
% prob 98.4, Match 957, R.Match 957

%% Define 3rd compound
index = 3;

% Sample info
mass_spectra_test_data(index).sample_name = data.sample.name;
mass_spectra_test_data(index).method_name = data.method.name;

% Sample data
retentionTime = 22.719;
mass_spectra_test_data(index).retention_time = retentionTime;
mass_spectra_test_data(index).mz = data.mz;
mass_spectra_test_data(index).intensity = ...
    data.xic(GetTimeIndex(data.time,retentionTime), :);

% NIST DB info
mass_spectra_test_data(index).compound_name = 'Propane';
mass_spectra_test_data(index).compound_formula = 'C3H8';
mass_spectra_test_data(index).compound_inchikey = 'ATUOYWHBWRKTHZ-UHFFFAOYSA-N';
mass_spectra_test_data(index).compound_exact_mass = 44.0626004;
mass_spectra_test_data(index).compound_score = 94.7;
% prob 94.7, Match 940, R.Match 940

%% Define 4th compound
index = 4;

% Sample info
mass_spectra_test_data(index).sample_name = data.sample.name;
mass_spectra_test_data(index).method_name = data.method.name;

% Sample data
retentionTime = 50.287;
mass_spectra_test_data(index).retention_time = retentionTime;
mass_spectra_test_data(index).mz = data.mz;
mass_spectra_test_data(index).intensity = ...
    data.xic(GetTimeIndex(data.time,retentionTime), :);

% NIST DB info
mass_spectra_test_data(index).compound_name = 'Methyl vinyl ketone';
mass_spectra_test_data(index).compound_formula = 'C4H6O';
mass_spectra_test_data(index).compound_inchikey = 'FUSUHKVFWTUUBE-UHFFFAOYSA-N';
mass_spectra_test_data(index).compound_exact_mass = 70.041865;
mass_spectra_test_data(index).compound_score = 86.9;
% prob 86.9, Match 895, R.Match 917

%% Define 5th compound
index = 5;

% Sample info
mass_spectra_test_data(index).sample_name = data.sample.name;
mass_spectra_test_data(index).method_name = data.method.name;

% Sample data
retentionTime = 6.430;
mass_spectra_test_data(index).retention_time = retentionTime;
mass_spectra_test_data(index).mz = data.mz;
mass_spectra_test_data(index).intensity = ...
    data.xic(GetTimeIndex(data.time,retentionTime), :);

% NIST DB info
mass_spectra_test_data(index).compound_name = 'Fluoroform';
mass_spectra_test_data(index).compound_formula = 'CHF3';
mass_spectra_test_data(index).compound_inchikey = 'XPDWGBQVDMORPB-UHFFFAOYSA-N';
mass_spectra_test_data(index).compound_exact_mass = 70.0030346;
mass_spectra_test_data(index).compound_score = 91.1;
% prob 91.1, Match 914, R.Match 914

%% finds index of nearest time value in the array
function index = GetTimeIndex(timeArray, timeValue)  

[~,index] = min(abs(timeArray - timeValue));

end