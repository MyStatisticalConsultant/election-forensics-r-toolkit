# Doprinosi deskriptivnom modulu

[English](CONTRIBUTING.md)

Dobrodošli su dokumentovane prijave grešaka, provere reproduktivnosti, testovi, poboljšanje metapodataka, prevodi i novi analitički moduli. Za veće promene prvo otvoriti GitHub Issue da bi se razmotrili uzorak, metodologija i kompatibilnost izlaza.

1. Definisati novu meru, jedinicu analize, potrebne ulazne kolone, skup `Main` ili BM ispod 100, i postupanje sa `Size` i `Size_JHK`.
2. Dodati mali sintetički primer sa poznatim tačnim rezultatom; kad je moguće obaviti nezavisno poređenje sa jednom od tri proverene baze.
3. Ne menjati pripremljene RZS podatke i ne izbacivati BM bez vidljivog pravila. Nedefinisane udele ne zamenjivati nulom.
4. Sačuvati srpska slova u UTF-8 i ažurirati englesku i `_SER.md` dokumentaciju. Identifikatori promenljivih/matrica moraju ostati stabilni ili se promene moraju jasno navesti.
5. Izvršiti sedam testnih/izvršnih komandi iz README-a i navesti R/paket verzije. Ne slati generisane baze u Git kao izvorni kod.
6. Ne tvrditi da statistički signal sam dokazuje izbornu prevaru; navesti druga objašnjenja, neizvesnost i moguće kvalitativne izvore provere.

**Poznata buduća izmena:** položajna šema ulaznih RZS kolona treba da postane verzionisana šema po zaglavljima/ulogama pre podrške za nove administrativne podatke ili lokalne izbore. To je izmena prethodnog, a ne deskriptivnog modula.

Kôd je objavljen prema [MIT licenci](../../LICENSE). Autorsko pravo © 2026 Zlatko J. Kovačić.
