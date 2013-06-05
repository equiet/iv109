cd "c:\Program Files (x86)\NetLogo 5.0.4"

for /l %%i in (38,1,56) do (
java -server -Xmx2048m -Dfile.encoding=UTF-8 -cp NetLogo.jar org.nlogo.headless.Main --threads 3 --model c:\Users\Santas\Documents\GitHub\iv109\traffic.nlogo --setup-file c:\Users\Santas\Documents\GitHub\iv109\experiments-setup.xml --experiment experiment%%i
)