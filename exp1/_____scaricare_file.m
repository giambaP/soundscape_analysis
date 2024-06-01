% soundscapes
clear all
close all

cart1 = './datasetDN/YAT1Audible';

files = [cart1 '/*.WAV'];

a = dir(files)
nfiles = length(a);
for i = 1:nfiles
    nomefile = a(i).name;
end


fd = fopen('bbbb.sh','w')
ora = 0;

    for i = 1:31
        for k = 0:23
           for j = 1:2
        % creazione nome file
        nm = '202003';
 
        if i < 10
            nm = strcat(nm,'0',num2str(i));
        else
            nm = strcat(nm,num2str(i));
        end
        nm = strcat(nm,'_');
    
            if k < 10
                nm = strcat(nm, '0', num2str(k)); 
            else 
                nm = strcat(nm, num2str(k));
            end
    
            if mod(j,2)
                nm = strcat(nm, '0000.WAV');
            else
                nm = strcat(nm, '3000.WAV');
            end
            j = 2;
        

        % creazione stringa wget
        s = ['wget http://colecciones.humboldt.org.co/rec/sonidos/publicaciones/MAP/JDT-Yataros/YAT1Audible/' nm];
        % scrittura nel file
        fprintf(fd,'%s\n',s);
           end
end
end
fclose(fd)



