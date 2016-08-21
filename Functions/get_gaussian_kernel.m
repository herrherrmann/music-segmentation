function [ C ] = get_gaussian_kernel( kernel_size )

% Original Checkerboard with appropriate kernel size.
A = [1 -1 ; -1 1];
B = ones(kernel_size);
C = kron(A, B);

% Create Gaussian taper.
x        = -(kernel_size-1):kernel_size; 
[X1, X2] = meshgrid(x);
mu       = [0 0];
Sigma    = [(8 * kernel_size) .4; .4 (8 * kernel_size)]; % Woher kommen .4 und 8?

F = mvnpdf([X1(:) X2(:)], mu, Sigma);
F = reshape(F, length(x), length(x));
F = F ./ max(max(F));

C = C .* F;
% surf(x, x, C);

end

