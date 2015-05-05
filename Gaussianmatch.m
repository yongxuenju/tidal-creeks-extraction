function aa=Gaussianmatch(f,sigma,siz)


os=18;  % 角度的个数

L=2;

x=-ceil(siz/2):ceil(siz/2);



thetas=0:(os-1);
thetas=thetas.*(180/os);

%N1=-tim*sigma:tim*sigma;

%N1=-exp(-(x.^2)/(2*sigma*sigma)).*((x.^2)-sigma*sigma);

N1=-exp(-(x.^2)/(2*sigma^2)).*((x.^2)-sigma^2)/(sqrt(2*pi)*sigma^5);




N=repmat(N1,[2*floor(L/2)+1,1]);


r2=floor(L/2);

% c2=floor(tim*sigma);

[m,n]=size(f);

RNs=cell(1,os);  % rotated kernals

MFRs=cell(1,os); % filtered images

g1=f;

 

% matched filter

for i=1:os

    theta=thetas(i);

    RN=imrotate(N,theta);

    %去掉多余的0行和零列

    RN=RN(:,any(RN));

    RN=RN(any(RN'),:);

    meanN=mean2(RN);

    RN=RN-meanN;

    RNs{1,i}=RN;

    MFRs{1,i}=imfilter(f,RN,'conv','symmetric');

end
% get the max response

g=MFRs{1,1};

for j=2:os

    g=max(g,MFRs{1,j});

end

 aa= im2double(g);

end

