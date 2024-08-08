clc; clear all; close all;

data = [
    1.0, 2.0, 3.0, 4.0;  % Punto 1
    2.0, 3.0, 1.0, 5.0;  % Punto 2
    3.0, 1.0, 2.0, 6.0;  % Punto 3
    4.0, 5.0, 6.0, 1.0;  % Punto 4
    5.0, 6.0, 4.0, 2.0   % Punto 5
];
labels = [1;0;1;1;1];

% vettore 1x10 considerando le combinazioni di ogni punto (sono 5) con
% gli altri, senza considerare le ripetizioni
% d=spqrt( (xP2​−xP1​)2+(yP2​−yP1​)2+(zP2​−zP1​)2+(wP2​−wP1​)2 )
% es posizione 1,1 il valore è 2.6458
% per tutti è 
% 2.64575131106459	3.16227766016838	6	6.08276253029822	2.64575131106459	7	6	7.61577310586391	7	2.64575131106459
dist = pdist(data(:,:));

% trasforma il vettore 1x10 in una matrice 5x5 dove per ogni punto abbiamo
% la distanza con gli altri (la matrice è diagolmente simmetrica)
% 0	2.64575131106459	3.16227766016838	6	6.08276253029822
% 2.64575131106459	0	2.64575131106459	7	6
% 3.16227766016838	2.64575131106459	0	7.61577310586391	7
% 6	7	7.61577310586391	0	2.64575131106459
% 6.08276253029822	6	7	2.64575131106459	0
sq = squareform(dist);

% aggiunge una matrice identità per evitare che ogni punto consideri sé
% stesso dato al punto 1,1 abbiamo 0 verrà preso sempre quello come minor
% distanza QUELLI SULLA DIAGONALE SONO QUELLI ESCLUSI NEL LEAVE ONE OUT PER
% OGNI CICLO
maxDist = sq+eye(size(data,1)).*max(sq(:));

% OGNI RIGA CORRISPONDE AD UNA CLASSIFICAZIONE DOVE IL MINIMO E' L'elemento
% che più si avvicina all'oggetto ciclato
[~,idx] = min(maxDist,[],2);

% PER OGNI CLASSIFICAZIONE, HO PRESO L'elemento più vicino, e di quello ne
% recupero la classe
assignedLabels = labels(idx);

% per ogni oggetto ho il risultato della sua classificazione in riga, la
% classe stimata, e quindi confronto poi con le label reali quanto mi sono
% avvicinato (il risultato è una media del leave one out per ogni elemento
err = sum(labels~=assignedLabels);
err = err/n;

