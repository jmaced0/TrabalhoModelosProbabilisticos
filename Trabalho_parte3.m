%Probabilidade de falso alarme
P_fa = [5e-4 5e-5 5e-6];

%Probabilidade de deteccao
P_d = [0.7 0.75 0.8 0.85 0.9];

%std do ruído branco
sigma = 1.0;

% Calculo do limiar cuja fórmula foi deduzida no relatório
W_T = 2 * sigma^2 * log (1 ./ P_fa);

% Determinacao do N minimo
z_confianca = 2.58; % 99% de confiança
erro_percentual = 0.005; % 0.5%
N = (1-P_d/10)*(z_confianca/erro_percentual)^2 ./ (P_d/10);
N = cast(N, 'uint64');

freq_rel = zeros (5,5);
SNR_db = zeros (5,5);


%tamanho do vetor
M = 10;

for fa = 1:3
    for d = 1:5
        %SNR e potencia do alvo
        SNR_movel = shnidman(P_d(d),P_fa(fa),1 ,1);
        SNR_db(fa,d) = SNR_movel;
        SNR_movel = db2pow(SNR_movel);
        potencia_alvo = (sigma^2)*2*SNR_movel;

        %Amostragem do alvo com fase seguindo uma distruibuição uniforme e
        %amplitude uma distribuição Rayleigh
        modulo = sqrt(-potencia_alvo*log(1-rand(N(d),1)));
        theta = pi * (rand(N(d),1) - 0.5);
        fase = exp(1i*theta);
        Z_alvo = modulo.*fase;

        %realizacaio do ruido
        Z = realizar_ruido(sigma, N(d),M);

        %somar sinal ao ruido
        Z(:,1) = Z(:,1) + Z_alvo;

        %Passar sinal pelo detector de lei quadratica
        W = (abs(Z)).^2;

        contador_alvo_detectado = sum(sum(W > W_T(fa)));

        freq_relativa_alvo_detectado = contador_alvo_detectado / cast(N(d), 'double');
        
        freq_rel(fa, d) = freq_relativa_alvo_detectado;
    end
end