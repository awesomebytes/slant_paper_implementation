clc;clear all;close all; 
% useful scripts from http://eeweb.poly.edu/iselesni/slantlet/index.html

% watermark image
W = imread('watermark_image.jpg');
W_double = double(W);

% original image
I=imread('lena.jpg');
I_double = double(I);

N=size(I);
if N(1) ~= N(2) % image must be squared... that sucks
   error('Error: not a square image')
end
   
N_watermark=size(W);
% watermark image
L_watermark = log2(N_watermark(1)); % getting the size of the image to compute the slant matrix
S_n_watermark = sltmtx(L_watermark); % compute slant matrix
S_nT_watermark = S_n_watermark'; % compute inverse slant matrix
U_watermark = W_double; % just to use same terminology than the paper
V_watermark = S_n_watermark * U_watermark * S_nT_watermark; % (1)
originalU_watermark = S_nT_watermark * V_watermark * S_n_watermark; % (2)

% DC component is the secret key file
secret_key = V_watermark(1,1);
% AC components are used for watermark embedding

originalU_watermark_img = uint8(originalU_watermark); % we need the image to be in uint8 to be visualized
figure('Name','Watermark and Slant transform')
subplot(2,2,1),imshow(W);
title('Original watermark');
subplot(2,2,2),imshow(originalU_watermark);
title('Watermark after slant applying');



% mysW = slantlt(W_double);
% figure('Name', 'slantlt Watermark')
% imshow( uint8(mysW) );
% figure('Name', 'slantfrommatrix watermark')
% imshow( uint8(V_watermark) )



% original image
L = log2(N(1)); % getting the size of the image to compute the slant matrix
S_n = sltmtx(L); % compute slant matrix
S_nT = S_n'; % compute inverse slant matrix
U = I_double;
% (x) come from http://www.surrey.ac.uk/computing/files/pdf/papers/Anthony_Ho/5_Ho_2003.pdf
V = S_n * U * S_nT; % (1)
originalU = S_nT * V * S_n; % (2)

originalU_img = uint8(originalU); % we need the image to be in uint8 to be visualized
figure('Name','Images and Slant transform')
subplot(2,2,1),imshow(I);
title('Original img');
subplot(2,2,2),imshow(originalU_img);
title('Image after slant applying');

% in V we can find the transform.
% from (0,0) (top left) we find the lower freqs (DC component)
% and in the bottom right we find the high freqs (AC components)

% we need to do the V = S * U * St for the watermark image
% 64x64
% from there we get the DC component (0,0) and save it in the "secret file"


% the original image I
% decompose in non-overlapped 8x8 sub-blocks
I_sub_8x8 = mat2cell(I_double,  [zeros(1,64) + 8], [ zeros(1,64) + 8]); % 64x64 of 8x8 blocks
I_sub_8x8_watermarked = I_sub_8x8; % we make a copy to put the watermark on

% we need a seed for random which will be secret too
secret_rng_seed = 42;
rng(secret_rng_seed); % supersecret seed
% get some random numbers here, quantity of them "m" in the paper
m = (64*64); % (64*64 watermark coefficients - 1 (DC coefficient))
m_subblocks = (64*64) / 16; % and we insert the coefficients by 16 in each subblock
m_subblocks = m_subblocks - 1; % substract last subblock that will have only 15 coefficients
% thats 256 by the way

% m-sequence random number generator for selecting a certain number of
% sub-blocks for watermark embedding
subblocks_for_water_embedding_row = randi([1 64], 1, m_subblocks);
subblocks_for_water_embedding_column = randi([1 64], 1, m_subblocks);

% in every subblock we select 16 values
% they follow scheme in paper (diagonal)
embedding_locations = [2 2; 3 2; 3 2; 3 3; 3 4; 4 3; 4 5; 4 6; 5 4; 5 5; 5 6; 6 5; 6 6; 6 7; 7 6; 7 7];


m_i=2; % m_i = 1 will be the DC coefficient so dont use it
S_n = sltmtx(log2(8)); % compute slant matrix of size 3, the size of the block
S_nT = S_n'; % compute inverse slant matrix
alpha = 0.1; % alpha of the paper is not described... 0.6 is a lot it seems, 0.1 is not so noticeable (but it is very much)
% watermark those locations for every subblock chosen to be watermarked
for current_subblock_to_watermark=1:m_subblocks
    U_subblock = cell2mat(I_sub_8x8(subblocks_for_water_embedding_row(current_subblock_to_watermark), subblocks_for_water_embedding_column(current_subblock_to_watermark)));
    V_subblock = S_n * U_subblock * S_nT; % (1) Slant transformed
    for i=1:16  % for every location
        location = embedding_locations(i,:);
        coef_to_insert = V_watermark((uint8(m_i)/64) +1, mod(m_i,64) +1); % this gets the next coefficient from the 64x64 watermark
        m_i = m_i+1;

        
        % IGNORE THIS NEXT COMMENTED LINES
        % one does not simply access a cell with cells... note the {}() structure
        %I_sub_8x8_watermarked{subblocks_for_water_embedding_row(current_subblock_to_watermark),
        %subblocks_for_water_embedding_column(current_subblock_to_watermark)}(location(1),location(2))
        %= whatever to insert here; % this recreates the full cell
        %structure for every change...
        % STOP IGNORING
        
        V_subblock(location(1),location(2)) = alpha * coef_to_insert;
    end
    watermarkedU_subblock = S_nT * V_subblock * S_n; % (2) recovered with the modified coefficients
    I_sub_8x8_watermarked{subblocks_for_water_embedding_row(current_subblock_to_watermark), subblocks_for_water_embedding_column(current_subblock_to_watermark)} = watermarkedU_subblock;
end

I_watermarked_double = cell2mat(I_sub_8x8_watermarked)
I_watermarked = uint8(I_watermarked_double)
figure('Name','Image and watermarked image')
subplot(2,2,1),imshow(I);
title('Original img');
subplot(2,2,2),imshow(I_watermarked);
title(sprintf('Image after watermark with alpha= %f', alpha));


%% Watermark detection
% We will need:
% secret_key --> the DC component, needed for some reason separated
% secret_rng_seed
% alpha

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
m_i=2; % m_i = 1 will be the DC coefficient so dont use it
S_n = sltmtx(log2(8)); % compute slant matrix of size 3, the size of the block
S_nT = S_n'; % compute inverse slant matrix
alpha = 0.1; % alpha of the paper is not described... 0.6 is a lot it seems, 0.1 is not so noticeable (but it is very much)
% watermark those locations for every subblock chosen to be watermarked
for current_subblock_to_detect=1:m_subblocks
    U_subblock = cell2mat(I_sub_8x8_watermarked(subblocks_for_water_embedding_row(current_subblock_to_detect), subblocks_for_water_embedding_column(current_subblock_to_detect)));
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


