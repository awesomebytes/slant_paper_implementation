slant_paper_implementation
==========================

This is a class project about implementing the paper Slant Transform Watermarking for Digital Images with MATLAB.

The paper can be found here:
http://www.surrey.ac.uk/computing/files/pdf/papers/Anthony_Ho/5_Ho_2003.pdf

The slant matrix generation are thanks to Ivan Selesnick:
http://eeweb.poly.edu/iselesni/slantlet/index.html


In this package you can find Slant matrix generated from order 2 to order 13 in the zip file called:
slant_matrix_order_2_to_13.zip

Or you can generate more if you want with the file:
compute_slant_matrices.m


There is a test file called test_insert_watermark_and_extract.m which contains a execution of the
implementation:
```matlab
% watermark to insert
W = imread('watermark_image.jpg');
% original image
%I = imread('lena.jpg');
I = rgb2gray (imread('baboon.jpg'));
rng_seed = 105;
alpha = 0.4; % the lower the better...
[watermarked_img, secret_key] = insert_watermark(I, W, rng_seed, alpha);
extracted_watermark = extract_watermark(watermarked_img, secret_key, rng_seed,
alpha);
```
The implementation is divided in the function insert_watermark and the function
extract_watermark.
There is also a file called watermark_.m which was my developing file.

Also in the directory you can find the images lena and baboon to test.

There is a PDF with some extra explanation.
