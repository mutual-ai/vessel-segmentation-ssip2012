function result=reconstruction(mask, marker)
    previousResult = zeros(size(marker, 1), size(marker, 2));
    result = marker;

    %figure('name', 'Reconstruction Mask'), imshow(mask);
    %figure('name', 'Reconstruction Marker'), imshow(marker);
    %figure('name', 'Reconstruction initial "result"'), imshow(result);
    %figure('name', 'Reconstruction initial "previous result"'), imshow(previousResult);
    
    
    reconstructionIteration = 0;
    %figure('name', 'Reconstruction Step');
    while ~(isequal(result, previousResult))
        reconstructionIteration = reconstructionIteration + 1;
        previousResult = result;
        result = imdilate(result, [0 1 0; 1 1 1; 0 1 0]);
        result = min(result, mask);

        %if mod(reconstructionIteration, 16) == 0 
        %  imshow(result);        
        %end
    end   
end