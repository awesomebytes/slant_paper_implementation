
for size_base_2=2:30
    L= size_base_2; % getting the size of the image to compute the slant matrix
    S_n = sltmtx(L); % compute slant matrix
    dlmwrite(sprintf('slant_matrix_order_%i.txt', size_base_2), S_n, 'delimiter', '\t', 'precision', 6)
    %S_nT = S_n'; % compute inverse slant matrix
    
end

