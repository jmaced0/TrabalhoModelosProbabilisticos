%Probabilidade de falso alarme
P_fa = [5e-4 1e-4 5e-5 1e-5 5e-6];

%Probabilidade de deteccao
P_d = 0.9;

%std do ruído branco
sigma = 1;

%calculo do N mínimo
z_confianca = 1.96; %95% de confiança
erro_percentual = 0.1; %10% porque menos que isso dá estouro de memória com 8GB de ram, no caso Pfa = 1e-6
N_min = (z_confianca/erro_percentual)^2 ./ P_fa;
N = cast(N_min,'uint64');
        
% Calculo do limiar cuja fórmula foi deduzida no relatório
W_T = 2 * sigma^2 * log (1 ./ P_fa);

freq_rel = zeros(5, 1);
potencia = zeros(5, 1);

for fa = 1:5        
        %variável aleatória complexa
        Z = realizar_ruido(sigma,N(fa), 1);

        %amplitude do ruido
        A = abs(Z);

        %detector com lei quadrática
        W = (A).^2;

        %calculo da quantidade de picos na realizacao do ruído
        deteccoes = length(find(W > W_T(fa)));

        %Frequencia relativa de falsos alarmes nas M realizacoes
        frequencia_relatica_Pfa = deteccoes ./ cast(N(fa),'double');
        
        freq_rel(fa) = frequencia_relatica_Pfa;
        potencia(fa) = var(Z);
end
