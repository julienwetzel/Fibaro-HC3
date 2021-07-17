# Informations
## LUA Scene
### Climat / Heating
- **FGT-001_Heat_Controller_Summer_mode.lua [No working !!!]**

   L'activation de cette scène va rechercher toutes les zones programmées ainsi que 
   toutes les vannes associées aux zones et désactive la programmation des zones puis
   configure les vannes FGT-001 au max (ManufacturerSpecific).

- **FGT-001_Heat_Controller_Normal_mode.lua**

   L'activation de cette scène va rechercher toutes les zones programmées ainsi que
   toutes les vannes associées aux zones et active la programmation des zones puis
   configure les vannes FGT-001 en mode heat (normal).

- **FGT-001_Heat_Controller_Open_Window.lua**

   L'activation de cette scène va rechercher dans quels vannes thermostatique FGT-001
   une fenêtre est détectée ouverte ou fermée et va ouvrir ou fermer toutes les vannes
   qui se trouvent dans la zone définie dans le panneau climat.

## QuickApp
### Windy Webcams
Ce module QuickApp intègre les webcams proches dans les caméras du HC3
Le site web Windy regroupe un grand nombre de webcams à travers le monde. Vous trouverez ici toutes les webcams disponibles. Tout ce que vous avez à faire est d'installer la QuickApp et vous aurez toutes les webcams sur votre HC3 à proximité de votre maison ou des emplacements définis dans votre HC3.
Pour l'utiliser, vous devez importer le fichier .fqa joint dans HC3 et ouvrir la console pour les instructions de configuration.
