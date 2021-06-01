%Probabilidade de falso alarme
P_fa = [5e-4 1e-4 5e-5 1e-5 5e-6];

%Probabilidade de deteccao
P_d = [0.7 0.75 0.8 0.85 0.9];

%std do ruído branco
sigma = 1.0;

% Calculo do limiar cuja fórmula foi deduzida no relatório
W_T = 2 * sigma^2 * log (1 ./ P_fa);

% Falta calcular valor de N
z_confianca = 2.58; % 99% de confiança
erro_percentual = 0.005; % 0.5%
N = (1-P_d)*(z_confianca/erro_percentual)^2 ./ P_d;
N = cast(N, 'uint64');


%tamanho do vetor
M = 10;

freq_rel = zeros (5,5);
for fa = 1:5
    for d = 1:5
        %Parte 2, adicao do alvo e tentativa de deteccao
        %Swerling 0

        %SNR a partir da equacao de Shnidman
        SNR_db = shnidman(P_d(d),P_fa(fa));
        SNR_mag = db2pow(SNR_db); 

        %Var(alvo) = SNR * Var(ruido)
        %          = SNR * 2*sigma^2
        %A variância é igual a potência para Z
        modulo = sigma*sqrt(2*SNR_mag);

        Z = realizar_ruido(sigma, N(d),M);

        %fase entre -pi/2 e pi/2
        theta = pi * (rand(N(d),1) - 0.5);
        fase = exp(1i*theta);    

        %número complexo com módulo fixo e fase aleatória
        Z_alvo = modulo*fase;

        %somar sinal ao ruido
        Z(:,1) = Z(:,1) + Z_alvo;

        %Passar sinal pelo detector de lei quadratica
        W = (abs(Z)).^2;
        clear Z;


        contador_alvo_detectado = sum(sum(W > W_T(fa)));

        freq_relativa_alvo_detectado = contador_alvo_detectado / cast(N(d), 'double');
        freq_rel(fa, d) = freq_relativa_alvo_detectado;

    end
end