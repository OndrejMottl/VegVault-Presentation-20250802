# **VegVault: 15-Minute Scientific Talk Outline**

## 1. Title Slide *(Displayed, not spoken)*

- **Title:** *VegVault: Linking Past and Present Vegetation Data for Global Change Research*
- **Presenter:** Ondřej Mottl, Charles University, Quantitative Ecology Lab
- **Date**, DOI, GitHub, and project website

---

## 2. Opening Hook: *"Ecology across millennia – still disconnected?"* *(0:15–1:30)*

- Most ecological models rely exclusively on contemporary data
- Yet ecosystems have evolved over millennia
- Vegetation data are fragmented across disciplines and repositories
- *What if we could integrate vegetation, climate, traits, and time into one coherent system?*

---

## 3. About Me *(1:30–2:30)*

- Assistant Professor at the Laboratory of Quantitative Ecology
- Focus areas: macroecology, palaeoecology, climate change, and large-scale data integration
- Advocate for Open Science and reproducibility in ecology
- Contact via personal webpage, GitHub, ORCID

---

## 4. What is VegVault? *(2:30–3:30)*

- A global SQLite database integrating plot-based paleo- and neo-vegetation data
- Links to functional traits, soil characteristics, and climate variables
- Built to support millennial-scale ecological analyses
- Fully open-source and reproducible infrastructure

---

## 5. Key Innovations *(3:30–4:00)*

- Paleo and contemporary data integrated across time
- Plot-based vegetation data (not just species occurrences)
- Sample-specific abiotic data (climate and soil)
- Standardised taxonomy and harmonised trait domains

---

## 6. Data & Technical Backbone *(4:00–5:00)*

- Data sources: Neotoma, BIEN, sPlotOpen, TRY, CHELSA, WoSIS
- Taxonomic harmonisation via GBIF backbone using `{taxospace}`
- Spatio-temporal linkage to abiotic grid points
- Structured, versioned pipelines and metadata

---

## 7. Access & Usability *(5:00–5:30)*

- R package `{vaultkeepr}` provides a user-friendly interface
- No SQL knowledge required; tidyverse-compatible workflows
- All code and data are public via GitHub and Zenodo
- Fully reproducible using version-controlled workflows

---

## 8. Example 1: *Picea* Distribution *(5:30–6:30)*

- Goal: Analyse the distribution of genus *Picea* across North America (0–15 ka BP)
- Combines fossil and contemporary vegetation plot data
- Filters by spatial extent and temporal range
- Taxa harmonised at the genus level using `{vaultkeepr}`

---

## 9. Example 2: CWM Trait Dynamics *(6:30–8:00)*

- Objective: Reconstruct community-weighted mean (CWM) of plant height
- Region: Central and South America; Period: 6–12 ka BP
- Combines trait data with fossil pollen records
- Application: functional biogeography and long-term ecosystem dynamics

---

## 10. Summary & Invitation *(8:00–9:00)*

- VegVault bridges temporal and disciplinary gaps in vegetation science
- Enables robust ecological synthesis and forecasting
- Scalable, transparent, and open by design
- We welcome collaborations and encourage the community to contribute and explore

---

## 11. Final Slide: Contact & Resources *(9:00–9:30)*

- Website, ORCID, GitHub, Lab page
- Include QR codes and short URLs for quick access
- Acknowledge collaborators, funders, and data providers

---

## Buffer Time & Optional Slides *(\~3 minutes for Q&A)*

- Optionally include one or more backup slides:
  - Full VegVault schema overview

