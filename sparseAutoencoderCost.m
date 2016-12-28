function [cost,grad] = sparseAutoencoderCost(theta, visibleSize, hiddenSize, ...
                                             lambda, sparsityParam, beta, data)

% visibleSize: the number of input units (probably 64) 
% hiddenSize: the number of hidden units (probably 25) 
% lambda: weight decay parameter
% sparsityParam: The desired average activation for the hidden units (denoted in the lecture
%                           notes by the greek alphabet rho, which looks like a lower-case "p").
% beta: weight of sparsity penalty term
% data: Our 64x10000 matrix containing the training data.  So, data(:,i) is the i-th training example. 
  
% The input theta is a vector (because minFunc expects the parameters to be a vector). 
% We first convert theta to the (W1, W2, b1, b2) matrix/vector format, so that this 
% follows the notation convention of the lecture notes. 

W1 = reshape(theta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
W2 = reshape(theta(hiddenSize*visibleSize+1:2*hiddenSize*visibleSize), visibleSize, hiddenSize);
b1 = theta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);
b2 = theta(2*hiddenSize*visibleSize+hiddenSize+1:end);

% Cost and gradient variables (your code needs to compute these values). 
% Here, we initialize them to zeros. 
cost = 0;
W1grad = zeros(size(W1)); 
W2grad = zeros(size(W2));
b1grad = zeros(size(b1)); 
b2grad = zeros(size(b2));

%% ---------- YOUR CODE HERE --------------------------------------
%  Instructions: Compute the cost/optimization objective J_sparse(W,b) for the Sparse Autoencoder,
%                and the corresponding gradients W1grad, W2grad, b1grad, b2grad.
%
% W1grad, W2grad, b1grad and b2grad should be computed using backpropagation.
% Note that W1grad has the same dimensions as W1, b1grad has the same dimensions
% as b1, etc.  Your code should set W1grad to be the partial derivative of J_sparse(W,b) with
% respect to W1.  I.e., W1grad(i,j) should be the partial derivative of J_sparse(W,b) 
% with respect to the input parameter W1(i,j).  Thus, W1grad should be equal to the term 
% [(1/m) \Delta W^{(1)} + \lambda W^{(1)}] in the last block of pseudo-code in Section 2.2 
% of the lecture notes (and similarly for W2grad, b1grad, b2grad).
% 
% Stated differently, if we were using batch gradient descent to optimize the parameters,
% the gradient descent update to W1 would be W1 := W1 - alpha * W1grad, and similarly for W2, b1, b2. 
% 

%%-------BEGIN OF MY CODE-----------------------------------------------
 numinstances = size(data, 2);
 %a2 = zeros(hiddenSize, numinstances);
 rho = sparsityParam;
 rhohat = zeros(hiddenSize, 1);
 mylambda = lambda;  mybeta = beta;  %% Just for the purpose of debugging
 %% loop over all of instances
% for i = 1 : numinstances
     %% feedforward pass to compute  'rhohat'
%     z2 = W1 * data(:,i) + b1; 
%     a2(:,i) = sigmoid(z2); %% store only a2 (no need to store a3)
%     rhohat = rhohat + a2(:,i);
% end  
 z2 = W1*data + repmat(b1,1,numinstances); %% matrix with size hiddenSize * numinstances
 a2 = sigmoid(z2); %% matrix
 z3 = W2*a2 + repmat(b2,1,numinstances);
 a3 = sigmoid(z3);
 rhohat = a2 * ones(numinstances, 1); %% sum of all columns of matrix a2
 rhohat = rhohat/numinstances;
 sparsity_delta = - rho ./ rhohat + (1 - rho) ./ (1 - rhohat); %% only used for calculating delta2
% for i = 1 : numinstances
%     z3 = W2 * a2(:,i) + b2;
%     a3 = sigmoid(z3);
%     %% backpropagation
%     delta3 = -(data(:,i)-a3).*a3.*(1-a3);
%     delta2 = (W2'*delta3 + mybeta*sparsity_delta).*a2(:,i).*(1-a2(:,i));
%     %% update 
%     W2grad = W2grad + delta3 * (a2(:,i)');
%     b2grad = b2grad + delta3;
%     W1grad = W1grad + delta2 * (data(:,i))'; 
%     b1grad = b1grad + delta2;
%     cost = cost + (a3 - data(:,i))' * (a3 - data(:,i));
% end       
 %% backpropagation
 delta3 = -(data-a3) .* a3 .* (1-a3); %% each column of delta3 corresponds to a vector delta of only one instance 
 delta2 = (W2'*delta3 + repmat(mybeta*sparsity_delta,1,numinstances)) .* a2 .* (1-a2);
 W2grad = W2grad + delta3 * (a2');
 b2grad = b2grad + delta3 * ones(numinstances, 1);
 W1grad = W1grad + delta2 * (data');
 b1grad = b1grad + delta2 * ones(numinstances, 1);
 W1grad = W1grad./numinstances + mylambda*W1;
 b1grad = b1grad/numinstances;
 W2grad = W2grad./numinstances + mylambda*W2;
 b2grad = b2grad/numinstances;
 cost = cost + ones(1, visibleSize) * ((a3-data).*(a3-data)) * ones(numinstances, 1);
 %% Here cost = J(W,b)
 cost = 0.5*cost/numinstances + 0.5*mylambda*(W1(:)'*W1(:)+W2(:)'*W2(:));
 %% Here cost = J(W,b)+beta*\sum_j KL(rho||rhohat_j) (i.e., J_sparse(W,b)
 kldiv = rho*log(rho./rhohat) + (1-rho)*log((1-rho)./(1-rhohat));
 cost = cost + mybeta*ones(1,hiddenSize)*kldiv;

%%-------END OF MY CODE-------------------------------------------------


%-------------------------------------------------------------------
% After computing the cost and gradient, we will convert the gradients back
% to a vector format (suitable for minFunc).  Specifically, we will unroll
% your gradient matrices into a vector.

grad = [W1grad(:) ; W2grad(:) ; b1grad(:) ; b2grad(:)];

end

%-------------------------------------------------------------------
% Here's an implementation of the sigmoid function, which you may find useful
% in your computation of the costs and the gradients.  This inputs a (row or
% column) vector (say (z1, z2, z3)) and returns (f(z1), f(z2), f(z3)). 

function sigm = sigmoid(x)
  
    sigm = 1 ./ (1 + exp(-x));
end

