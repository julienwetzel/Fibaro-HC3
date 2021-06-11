# Informations
## LUA Scene
### Climat / Heating
- **FGT-001_Heat_Controller_Summer_mode.lua**

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

