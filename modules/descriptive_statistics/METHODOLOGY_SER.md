# Metodologija i tumačenje — v0.3.1

[English](METHODOLOGY.md)

## Nivoi podataka

Osnovna jedinica ulaza je biračko mesto (BM). Tabele se računaju odvojeno za Republiku Srbiju, okruge prema RZS šifri i **kombinaciju šifre okruga i opštine**. Originalne šifre, nazivi i posebne administrativne kategorije ostaju sačuvane: takve kombinacije ne moraju se potpuno poklapati sa uobičajenim teritorijalnim opštinama. Ne spajati predsedničke i parlamentarne izbore iz iste godine bez posebnog istraživačkog dizajna.

## Kontrola kvaliteta i klasifikacije

`Main` je osnovni uzorak sa `E >= 100` i pozitivnim QC statusom. `Less than 100` uzima se iz `Master` uz **zasebnu proveru podobnosti**; `All = Main + prihvaćena BM ispod 100`. Tri grupe `Size` i dve grupe `Size_JHK` nezavisno dele `Main`. Pragovi se određuju na nivou države i ne menjaju po okrugu/opštini. [MAIN_SAMPLE_GUIDE_SER.md](MAIN_SAMPLE_GUIDE_SER.md).

## Zbirne stope i mere po BM

Za BM `i` neka su `E_i` upisani birači, `C_i` ubačeni listići, `B_i` važeći, `I_i` nevažeći, `A_i` evidentirani izlazak, a `V_ki` glasovi za opciju `k`.

- Zbirna izlaznost = `100 × ΣC_i / ΣE_i`; evidentirani izlazak = `100 × ΣA_i / ΣE_i`.
- Udeo nevažećih među ubačenim = `100 × ΣI_i / ΣC_i`.
- Udeo kandidata/liste među važećim = `100 × ΣV_ki / ΣB_i`.
- Udeo kandidata/liste među upisanim = `100 × ΣV_ki / ΣE_i`.
- Neponderisana srednja izlaznost po BM = aritmetička sredina vrednosti `100 × C_i/E_i`.

**Zbirna stopa i neponderisani prosek nisu isto.** Primera radi, BM sa 100 upisanih i izlaznošću 80% i BM sa 900 upisanih i izlaznošću 40% imaju prost prosek izlaznosti 60%, ali zbirnu izlaznost `(80+360)/(100+900) × 100 = 44%`. Uvek navesti koji je pokazatelj prikazan.

Nacionalno prve dve opcije određuju se jednom po izborima i ostaju iste u svim područjima. Lokalno prvoplasirana i drugoplasirana opcija računaju se zasebno. *Efektivan broj izbornih opcija* (*effective number of options*) je `1/Σp_k²`, gde je `p_k` udeo glasova u važećim listićima. Primer za udela 0,50/0,30/0,20: vrednost je `2,63`. Pokazuje koncentraciju glasova, ne integritet izbora.

## Robusne distribucione mere

Za `E`, izlaznost BM, udeo nacionalno prvoplasirane opcije i udeo nevažećih računaju se N, sredina, medijana, standardna devijacija uzorka (SD), Q1/Q3, interkvartilni raspon (IQR), P10/P90 i autlajeri prema Tukijevoj granici `[Q1−1,5×IQR, Q3+1,5×IQR]`. Autlajer je **statistički neuobičajena vrednost**, a ne potvrđena nepravilnost. Male i homogene grupe mogu imati IQR=0 ili nedefinisanu SD.

## Zajednička raspodela i testovi

Tabela izlaznost × udeo nacionalnog pobednika koristi intervale širine 10 procentnih poena i broji **BM**, ne glasove. Pirsonov i Spirmanov koeficijent označeni kao `Joint_*` računaju se po BM u grupi, a ne na nivou okruga kao jednog agregatnog zapisa.

**Kruskal–Volisov test** (*Kruskal–Wallis*) poredi tri disjunktne grupe `Small/Middle/Large` za izlaznost i udeo pobednika, dok **Vilkoksonov test rang-suma** (*Wilcoxon rank-sum*, Mann–Whitney) poredi `JHK Small` i celokupnu komplementarnu `JHK Large` grupu. Testovi su stvarno sprovedeni nacionalno i unutar teritorijalnih jedinica tamo gde postoje potrebni podaci i varijabilnost. BH q-korekcija primenjuje se **u okviru teritorijalnog nivoa × pokazatelja × porodice testa, preko područja**, ne globalno preko svih izlaza.

## Korelacije među područjima

Korelacione matrice računaju veze između **agregata okruga/opština**, ne između BM u svakom okrugu. Dvostrana nominalna `p<0,05` označena je zvezdicom; BH q-vrednosti koriguju poređenja **unutar svake matrice**. Korelacije zbirnih brojeva često nastaju mehanički usled veličine područja ili deljenja imenilaca. [CORRELATIONS_SER.md](CORRELATIONS_SER.md).

## Domet forenzičkog zaključivanja

Program proverava identitete listića i glasova, slaganje podskupova i rekonstrukciju `Main`, ali sam ne dokazuje kvalitet zvaničnog izvora niti izbornu prevaru. Neuobičajene vrednosti mogu nastati zbog demografije, geografije, izlaznosti, političke strukture, greške unosa ili nepravilnosti. Za dalju istragu potrebni su zapisnici BM, dokumentacija o ponovnom brojanju, izveštaji posmatrača, prigovori i drugi kvalitativni izvori. Dokumentovana razlika u broju upisanih 2017. ostaje posebna stavka za proveru u modulu pripreme.
