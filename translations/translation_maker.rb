require "json"
all_translation_files=Dir.glob("*.{json}")

transl={}
out = "id"
for translation_file in all_translation_files
    p translation_file.to_s[0..1]
    out+= ","+translation_file.to_s[0..1]
    transl[translation_file.to_s[0..1]]=JSON.parse(File.read(translation_file))
    #p JSON.parse(File.read(translation_file))
    #JSON.parse
end
p transl

out+="\n"

for key in transl["en"].keys()
    #p "key=#{key}"
   # p "transl.keys()=#{transl.keys()}"
    out+="#{key}"
    for lang in transl.keys()
        #p "lang=#{lang}"
        out+=","+transl[lang][key]
    end
    out+="\n"
end
File.write("default\\output.csv",out)
    
