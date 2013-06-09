clc;clear all;close all; 

% watermark to insert
W = imread('watermark_image.jpg');

% original image
%I = imread('lena.jpg');
I = rgb2gray (imread('baboon.jpg'));

rng_seed = 105;
alpha = 0.4; % the lower the better...
[watermarked_img, secret_key] = insert_watermark(I, W, rng_seed, alpha);

extracted_watermark = extract_watermark(watermarked_img, secret_key, rng_seed, alpha);

resized_watermarked_img = imresize(watermarked_img, [256 256])
recovered_size_watermarked_img = imresize(watermarked_img, [512 512])

extracted_watermark_from_resized = extract_watermark(recovered_size_watermarked_img, secret_key, rng_seed, alpha);



