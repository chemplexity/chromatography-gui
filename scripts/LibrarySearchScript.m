ms_data = ImportAgilent2();

%% Cleanup Library
delete_index = [];

for i = 1:length(library)
    
    % Remove any spectra with just one point
    if length(library(i).mz) == 1
        delete_index(end+1) = i;
    end
    
    % Remove any spectra with NaN values
    if any(isnan(library(i).mz))
        delete_index(end+1) = i;
    end
end

library(delete_index) = [];

%%

% Get library min/max mz limits
min_mz = min(cellfun(@(x) min(x), {library.mz}));
max_mz = max(cellfun(@(x) max(x), {library.mz}));
mz_span = max_mz - min_mz + 1;

% Get the mz step size from library spectra
mz_step = 1;%min(cellfun(@(x) min(x), cellfun(@(x) diff(x), {library.mz}, 'UniformOutput', false)));

% Initialize match matrix
match_mz = min_mz : mz_step : max_mz;
match_intensity = zeros(length(library(:,1)), mz_span);

% Fill in library intensity
for i = 1:length(library(:,1))
    
    % Get index for each m/z value
    for j = 1:length(library(i).mz)
        index = round(library(i).mz(j)) - min_mz + 1;
        match_intensity(i, index) = library(i).intensity(j);
    end
end

% Normalize library intensity
for i = 1:length(match_intensity(:,1))
    match_intensity(i,:) = match_intensity(i,:) / max(match_intensity(i,:));
end

%%
idx = 1;

% Crop test data
temp_mz = mass_spectra_test_data(idx).mz(mass_spectra_test_data(idx).mz >= min_mz & mass_spectra_test_data(idx).mz <= max_mz);
temp_intensity = mass_spectra_test_data(idx).intensity(mass_spectra_test_data(idx).mz >= min_mz & mass_spectra_test_data(idx).mz <= max_mz);
test_intensity = zeros(1, length(match_mz));

% Bin test data
for i = 1:length(temp_mz(1,:))
    
    % Get index to transfer value to
    index = find(match_mz == round(temp_mz(1,i)));
    
    % Sum intensity values into same mz bin
    test_intensity(1, index) = test_intensity(1, index) + temp_intensity(1,i);
end

% Normalize test intensity
 test_intensity =  (test_intensity - min(test_intensity)) / (max(test_intensity) - min(test_intensity));
 
% Spectra similiarty
spectra_similarity_1 = sum((test_intensity .* match_intensity) .^ 0.5, 2);
spectra_similarity_2 = (sum(match_intensity, 2) .* sum(test_intensity)) .^ 0.5;
spectra_similarity = spectra_similarity_1 ./ spectra_similarity_2 .* 100;

% Get top match
best_score = max(spectra_similarity);
best_index = find(spectra_similarity == best_score);
best_match = library(best_index(1));

%%
cla;
hold all;
plot(match_mz, test_intensity, 'color', 'black');
plot(match_mz, match_intensity(best_index, :), 'color', 'red');

%%
MassSpectra(mass_spectra_test_data(idx).mz, mass_spectra_test_data(idx).intensity, 'xlim', [0,300])
%%
MassSpectra(match_mz + 0.1, match_intensity(best_index(1), :), 'xlim', [0,300], 'barwidth', 0.7)
%%
MassSpectra(best_match.mz + 0.1, best_match.intensity, 'xlim', [0,300], 'barwidth', 0.7)