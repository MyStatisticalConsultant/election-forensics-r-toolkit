# Uputstvo za izlazne rezultate

[English](OUTPUT_GUIDE.md)

Skript pravi odvojen direktorijum `klimek_outputs/<vrsta_izbora>_<godina>/` za svake izbore, relativno od `modules/klimek`, osim ako ne promenite `OUTPUT_DIR`.

| Datoteka/direktorijum | Sadržaj |
|---|---|
| `<id>_klimek_summary.xlsx` | Uređeni Excel listovi `Metadata`, `Coverage`, `Options`, `National`, `District`, `Municipality`, `Areas`, `Tail_metrics` |
| `<id>_curve_endpoints.xlsx` | Krajnje vrednosti svih nacionalnih krivih, uključujući opcije koje nisu nacrtane |
| `tables/metadata.csv` | Konfiguracija i MD5 pripremljene baze |
| `tables/coverage.csv` | Broj BM, birača i listića za osam grupa |
| `tables/options.csv` | Nazivi i redosled svih kandidata/lista, prevodi EN/SR |
| `tables/national.csv` | Nacionalno: osam grupa × sve izborne opcije |
| `tables/district.csv`, `tables/municipality.csv` | Svi okruzi/opštine × grupa × opcija |
| `tables/areas.csv` | Rečnik šifara područja i složenih opštinskih ključeva |
| `tables/tail_metrics.csv` | Opcione T90/T95 metrike; prazna tabela ako su isključene |
| `tables/curve_endpoints.csv` | Krajnje vrednosti i imenitelji nacionalnih krivih |
| `curves/national/<grupa>_<opcija>.csv` | Tačke svih nacionalnih krivih ako su uključene |
| `curves/<odabrana-oblast>_...csv` | Tačke dodatnih geografskih krivih |
| `figures/<EN|SR>/<valid|option>/<oblast>/A_<grupa>_<combined|faceted>.<png|pdf>` | Više opcija u istoj grupi BM |
| `figures/<EN|SR>/<valid|option>/<oblast>/B_<opcija>_<combined|faceted>.<png|pdf>` | Jedna opcija u različitim grupama BM |

CSV datoteke su UTF-8 sa BOM radi dijakritika u Excel-u; XLSX čuva Unicode. Dugačke serije tačaka se ne uključuju u Excel jer mogu premašiti dozvoljen broj redova. Izlazi se ne postavljaju u glavni Git repozitorijum. Ako nedostaje slika za grupu bez važećih glasova ili opciju bez glasova, to nije automatski programska greška: prvo proverite `coverage.csv` i `curve_endpoints.csv`.
