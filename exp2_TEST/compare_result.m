clc; close all; clear all;



% checking compatibility
disp("");
disp("-----  CHECKING COMPATIBILITY ----");
dirTemplateNew = "./TEST_templates_NEW";
dirTemplateOriginal = "./TEST_templates_OLD";
fileList = dir(dirTemplateOriginal);
fileList = fileList(~[fileList.isdir]);
for i=1:length(fileList)
    fileName = fileList(i, :).name;
    fprintf("%d. checking file %s\n", i, fileName);

    origFilePath = sprintf("%s/%s", dirTemplateOriginal, fileName);
    newFilePath = sprintf("%s/%s", dirTemplateNew, fileName);
    if ~exist(newFilePath , "file")
        error("feature file not exist final path: feature '%s'\n", fileName);
    else
        data1 = load(origFilePath);
        data2 = load(newFilePath);

        fields1 = fieldnames(data1);
        fields2 = fieldnames(data2);

        if ~isequal(fields1, fields2)
            error("feature content files are different: file '%s', field '%s'", fileName, fields1);
        else
            isEqual = true;
            for j = 1:length(fields1)
                d1 = data1.(fields1{j});
                d2 = data2.(fields2{j});
                if ~isequal(d1, d2)
                    error("feature content fields are different: file '%s', field '%s', posJ:'%d'", ...
                        fileName, fields1{j}, j);
                end
            end
        end
    end
end
