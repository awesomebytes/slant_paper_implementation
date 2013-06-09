function watermark_extracted = extract_watermark(watermarked_image, secret_key, secret_rng_seed, alpha)
%
% Extract the watermark of a watermarked image
% given the necessary data
% secret key (the DC component)
% the random number generator seed
% the alpha used for embedding
%
% returns the extracted watermark
%       

watermarked_image_double = double(watermarked_image);
watermarked_image_sub_8x8 =  mat2cell(watermarked_image_double,  [zeros(1,64) + 8], [ zeros(1,64) + 8]); % 64x64 of 8x8 blocks for the 512x512 img

% set random number generator seed
rng(secret_rng_seed);
m = (64*64); % (64*64 watermark coefficients - 1 (DC coefficient)) will be taken into account when iterating
m_subblocks = (64*64) / 16; % and we insert the coefficients by 16 in each subblock
m_subblocks = m_subblocks - 1; % substract last subblock that will have only 15 coefficients
% generate the subblocks that were watermarked
subblocks_for_water_embedding_row = randi([1 64], 1, m_subblocks);
subblocks_for_water_embedding_column = randi([1 64], 1, m_subblocks);

% in every subblock we select 16 values
% they follow scheme in paper (diagonal)
embedding_locations = [2 2; 3 2; 3 2; 3 3; 3 4; 4 3; 4 5; 4 6; 5 4; 5 5; 5 6; 6 5; 6 6; 6 7; 7 6; 7 7];


detected_watermark_slant = zeros(64,64);
detected_watermark_slant(1,1) = secret_key;
m_i=2; % m_i = 1 is the DC coefficient
S_n = sltmtx(log2(8)); % compute slant matrix of size 3, the size of the block
S_nT = S_n'; % compute inverse slant matrix
% extract watermark coefficients from the blocks
for current_subblock_to_detect=1:m_subblocks
    U_subblock = cell2mat(watermarked_image_sub_8x8(subblocks_for_water_embedding_row(current_subblock_to_detect), subblocks_for_water_embedding_column(current_subblock_to_detect)));
    V_subblock = S_n * U_subblock * S_nT; % (1) Slant transformed
    for i=1:16  % for every location
        location = embedding_locations(i,:);
        detected_watermark_slant((uint8(m_i)/64) +1, mod(m_i,64) +1) = V_subblock(location(1),location(2)) / alpha; % store each coef
        m_i = m_i+1;
    end
end

S_n = sltmtx(log2(64)); % compute slant matrix of size 6, the size of the watermark image
S_nT = S_n'; % compute inverse slant matrix
detected_watermark_double = S_nT * detected_watermark_slant * S_n; % We recover the watermark
detected_watermark = uint8(detected_watermark_double);

figure('Name','Recovered watermark');
imshow(detected_watermark);

% store in disk the watermark found
imwrite(detected_watermark, 'detected_watermark.jpg','jpg');

% return the detected watermark in imshow-able format
watermark_extracted = detected_watermark;
