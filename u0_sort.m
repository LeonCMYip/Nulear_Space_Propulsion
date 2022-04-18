function ui = u0_sort(u0_length)

L = length(u0_length);
u0_length = u0_length-1;

ui(1,1) = 1;
ui(1,2) = ui(1,1) + u0_length(1);

ui(2,1) = 2;
ui(2,2) =  ui(2,1) + u0_length(2);

for i = 3:L

    ui(i,1) = ui(i-1,2)+1;
    ui(i,2) = ui(i,1) + u0_length(i);

end

end