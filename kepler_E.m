function E = kepler_E(e, M)

TOL = 10e-6;

Ei = (M - e/2);

for i = 1:1:100
    
    fEi = Ei - e * sin(Ei) - M;
    dEi = 1 - e * cos(Ei);
    
    ratio = fEi/dEi;
    
    if(abs(ratio) < TOL)
        E = Ei;
        break;
    end

   Enext = Ei - fEi/dEi;
   
   Ei = Enext;

end

if i == 100
E = 0;
disp("ERROR E did not converge [kelper_e]")
end




