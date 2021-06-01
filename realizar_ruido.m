function Z = realizar_ruido(sigma,N, M)
%sigma = desvio padrao do ruido
%Z = vetor contendo (N,M) realizacoes do ruido
%N = quantidade de realizacoes
%M = tamanho do pulso

%definicao do ruido branco
Z = normrnd(0,sigma,[N,M]) + 1i*normrnd(0,sigma,[N,M]);


