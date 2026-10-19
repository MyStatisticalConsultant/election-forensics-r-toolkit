# Election Forensics R Toolkit v1.6.1-dev — uzorak sa najmanje 100 birača

U deskriptivnom modulu v0.3.1 uvedena je eksplicitna grupa **100 or more** koja je jednaka radnom listu `Main` iz `RZS_data_preparation.R`, na svim geografskim nivoima i u Word tabelama. Grupa `All` i dalje obuhvata Main i QC-prihvaćena biračka mesta sa manje od 100 upisanih. Obe klasifikacije (`Size`, `Size_JHK`) zasebno rekonstrušu Main.

Dodate su dve korelacione matrice (`D_08`, `M_08`), odnosno **16 matrica po izborima**, uz očuvanje ranijih identifikatora 01–07. Proširene su provere usaglašenosti. Nisu menjani RZS modul, glasovi, pragovi klasifikacije ni specifikacije statističkih testova.

**Razvojni status:** potrebna je lokalna provera R kodova i izvoznih rezultata pre stabilne verzije.
