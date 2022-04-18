function M = calcualteFuelMass(P,nr,en)
%Power P
%Neutron Rate nr
%Enrichment en%
%Number of U235 nuclei N_U235

%Fission cross section
sigma_f  = 576e-28;
%Useful energy per fission
E = 3.2e-11; %200 MeV
%Atmoic mass of natural Uranium
A = 238.03; %g/mol
%Avogardo's Number
Na = 6.022e26; %in kmol

N_U235 = P/(nr*sigma_f*E);
M = (N_U235*A)/(Na*en);

end