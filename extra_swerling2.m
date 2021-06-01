%Probabilidade de falso alarme
P_fa = 5e-6;

%Probabilidade de deteccao
P_d = 0.7;

%std do ruído branco
sigma = 1;

% Calculo do limiar cuja fórmula foi deduzida no relatório
W_T = 2 * sigma^2 * log (1 / P_fa);

% Falta calcular valor de N
z_confianca = 2.58; % 99% de confiança
erro_percentual = 0.005; % 0.5%
N = (1-P_d)*(z_confianca/erro_percentual)^2 / P_d;
N = cast(N, 'uint64');

%Parte 3

%tamanho do pulso
M = 12;

k = 0.5:0.01:0.8;

%varrendo a força bruta até encontrar a frequencia relatica semelhante ao
%item anterior para poder comparar a SNR
for r = 1:101
   
    %filtro casado que pré processará o pulso
    forma_onda = ones(M,1);
    filtro_casado = conj(forma_onda((end:-1:1)));
    filtro_casado = filtro_casado / (norm(filtro_casado)); %ganho unitario
    %ganho_filtro = (filtro_casado.')*filtro_casado;

    %SNR e potencia do alvo
    SNR_movel = shnidman(P_d,P_fa,M,2);
    SNR_movel = db2pow(SNR_movel);
    
    
    if M > 1
        fator_correcao = k(r)*sqrt(M);
        %nao consegui calcular, provavelmente eu não deveria usar a funcao
        %shnidman
        SNR_movel = SNR_movel * fator_correcao;
    end

    potencia_alvo = 2*(sigma^2)*SNR_movel;

    %Amostragem do alvo com fase seguindo uma distruibuição uniforme e
    %amplitude uma distribuição Rayleigh
    modulo = sqrt(-potencia_alvo*log(1-rand(N,1)))*forma_onda.';
    theta = pi* (rand(N,M) - 0.5);
    fase = exp(1i*theta);
    Z_alvo = (modulo.*fase);

    
    %realizacao do ruido
    Z = realizar_ruido(sigma, N,M);

    %somar sinal ao ruido
    Z = (Z + Z_alvo);
    Z = Z*filtro_casado;
    %Passar pelo detector de lei quadratica
    W = ((abs(Z)).^2);

    contador_alvo_detectado = sum(W > W_T);

    freq_relativa_alvo_detectado = contador_alvo_detectado / cast(N, 'double');
    
    if (freq_relativa_alvo_detectado < 1.005*P_d) && (freq_relativa_alvo_detectado > P_d)
        k(r)
        freq_relativa_alvo_detectado
        pow2db(SNR_movel)
        break
    end
        
end