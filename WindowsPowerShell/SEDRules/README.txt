> pustit v powershellu , musi byt nainstalovany GIT a spraven cesty v Enviroment Variables
> kontrola sedu - sed nebo which sed, powershell by ho mel poznat jinak napise ze nezna prikaz sed
> mozna lepsi poustet v CMD kvuli zachovani kodovani
gc C:\Users\ttintera\!Develop\!ALM\RunMe\EXTREP.IASCONSO_DETAIL4.txt | sed.exe -Ef C:\Users\ttintera\!Develop\!ALM\RunMe\sedIasbale.txt | Out-File C:\Users\ttintera\!Develop\!ALM\RunMe\EXTREP.IASCONSO_DETAILres4.txt
cat c:\Users\ttintera\!Develop\!ALM\RunMe\CSC.CKLIST_ADD.txt | sed.exe -Ef c:\Users\ttintera\!Develop\!ALM\RunMe\sedCklistAdd.txt > c:\Users\ttintera\!Develop\!ALM\RunMe\res.txt