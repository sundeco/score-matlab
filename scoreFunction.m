%first rescale each phantom image (make the patches better)
%note that there is some downsampling interpolation leading to negatives
lsize = 64;
numimages = 1000;
y = zeros(lsize, lsize, numimages);
for i = 1:numimages
    y(:,:,i) = imresize(squeeze(x(:,:,i)), [lsize lsize]);
end

%next, collect some patches from these phantoms 
psize = 3;
patchesPerImage = 2;
patchArr = zeros(psize, psize, patchesPerImage * numimages);
a = 1;
for i = 1:numimages
    myim = squeeze(y(:,:,i));
    for j = 1:patchesPerImage
        row = randi([1 lsize - psize + 1]);
        col = randi([1 lsize - psize + 1]);
        myPatch = myim(row:row+psize-1, col:col+psize-1);
        patchArr(:,:,a) = myPatch;
        a = a+1;
    end
end

%for each x (a patch), i have the outer loop p(x) 
%i want to generate the inner loop xhat corresponding to adding noise 
sigma = 0.05;
imPerPatch = 10;
input = zeros(psize, psize, patchesPerImage * numimages * imPerPatch);
output = input; 
a = 1;
for i = 1:patchesPerImage * numimages
    for j = 1:imPerPatch
        %add some noise to the patch
        xhat = squeeze(patchArr(:,:,i)) + sigma * randn(psize, psize);
        input(:,:,a) = xhat;
        output(:,:,a) = (squeeze(patchArr(:,:,i)) - xhat)/sigma^2;
        a = a+1;
    end
end
output = output * sigma;
totalPts = patchesPerImage * numimages * imPerPatch;

%%
%train the neural network to map input to output
layers = [
    featureInputLayer(psize*psize,'Name','input')
    fullyConnectedLayer(40, 'Name', 'fc6400')
     leakyReluLayer
    fullyConnectedLayer(80, 'Name', 'fc320')
     leakyReluLayer
    fullyConnectedLayer(160, 'Name', 'fc160')
     leakyReluLayer
     fullyConnectedLayer(320, 'Name', 'fc160')
     leakyReluLayer
     fullyConnectedLayer(320, 'Name', 'fc160')
     leakyReluLayer
    fullyConnectedLayer(160, 'Name', 'fc80')
     tanhLayer
    fullyConnectedLayer(80, 'Name', 'fc40')
     tanhLayer
    fullyConnectedLayer(40, 'Name', 'fc20')
     tanhLayer
%      fullyConnectedLayer(10, 'Name', 'fc10')
%      leakyReluLayer
    fullyConnectedLayer(psize*psize, 'Name', 'fc')
    %reluLayer('Name', 'RELU')
    regressionLayer];
options = trainingOptions('sgdm', ...
    'MaxEpochs', 1000, ...
    'InitialLearnRate',0.001, ...
    'Verbose',false, ...
    'Plots','training-progress');
trainx = reshape(input, psize^2, totalPts); 
trainy = reshape(output, psize^2, totalPts); 
[net, info] = trainNetwork(trainx', trainy', layers, options);

%%
%take a clean image and add noise, then begin gradient descent to find MAP
%estimate 
clean = squeeze(y(:,:,1));
noisy = clean + sigma * randn(lsize, lsize);
xk = noisy;
alpha = 0.001; %is there a better way to choose this parameter?
overlap = 1;
overlaparr = getDivision(lsize, psize, overlap);
iters = 1000;
images = zeros(iters, lsize, lsize);
lastpsnr = 0;
for i = 1:iters
    images(i,:,:) = xk;
    xk = xk + alpha * ((noisy-xk)/sigma^2 + score(xk, net, overlaparr, overlap, psize)/sigma);
    curpsnr = psnr(squeeze(images(i,:,:)), clean)
    if abs(curpsnr-lastpsnr) < 0.02
        %images(i+1,:,:) = xk;
        subplot(1,2,1);
        imshow(squeeze(images(1,:,:)))
        title(sprintf('Noisy image, %d', i))
        subplot(1,2,2);
        imshow(squeeze(images(i,:,:)))
        title('Denoised image')
        pause(0.1)
        %scale the output image affinely, turns out it's unnecessary
        %realout = findScale(squeeze(images(7,:,:)), clean);
        %psnr(realout, clean)
        %break
    end
    lastpsnr = curpsnr;
end

%try comparing with TV denoising

