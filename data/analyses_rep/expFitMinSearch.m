function expFitMinSearch(x,data)

pred=x(2)+(x(1)-x(2))*exp(-(0:(length(data)-1))/x(3));
rmse=sqrt((data-pred).^2);
end