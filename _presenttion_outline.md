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

## 4. Imagine a Project: *Functional Stability in the Rocky Mountains* *(2:30–4:00)*

- Research question: *"Did vegetation in the Rocky Mountains maintain functional stability from the Last Glacial Maximum to the present?"*
- What data would we need?
  - Fossil pollen and modern plot-based vegetation data
  - Functional trait data (e.g., plant height, SLA, wood density)
  - Past and present climate data
- Challenges:
  - Data come from different sources and formats
  - Varying taxonomies and sampling methods
  - Complex filtering by time, space, and traits
  - Integrating abiotic and trait dimensions requires extensive coding and data wrangling

---

## 5. Solving It with VegVault *(4:00–5:00)*

- Imagine answering this question with just a few lines of code
- Use `{vaultkeepr}` to:
  - Access vegetation, trait, and climate data simultaneously
  - Filter by time range, spatial boundaries, and taxa
  - Harmonise taxonomy and retrieve community-weighted traits
- Minimal code, maximum reproducibility

---

## 6. What is VegVault? *(5:00–6:00)*

- A global SQLite database integrating plot-based paleo- and neo-vegetation data
- Links to functional traits, soil characteristics, and climate variables
- Built to support millennial-scale ecological analyses
- Fully open-source and reproducible infrastructure

---

## 7. Key Innovations *(6:00–6:30)*

- Paleo and contemporary data integrated across time
- Plot-based vegetation data (not just species occurrences)
- Sample-specific abiotic data (climate and soil)
- Standardised taxonomy and harmonised trait domains

---

## 8. Data & Technical Backbone *(6:30–7:00)*

- Data sources: Neotoma, BIEN, sPlotOpen, TRY, CHELSA, WoSIS
- Taxonomic harmonisation via GBIF backbone using `{taxospace}`
- Spatio-temporal linkage to abiotic grid points
- Structured, versioned pipelines and metadata

---

## 9. Access & Usability *(7:00–7:30)*

- R package `{vaultkeepr}` provides a user-friendly interface
- No SQL knowledge required; tidyverse-compatible workflows
- All code and data are public via GitHub and Zenodo
- Fully reproducible using version-controlled workflows

---

## 10. Other Potential Applications *(7:30–8:30)

Some examples to highlight VegVault’s flexibility for vegetation science, palaeoecology, and macroecology

- Identifying trait–environment mismatches under past and future climate change
- Analyzing biome transitions through functional and taxonomic dissimilarity
- Reconstructing long-term community assembly based using JSDM
- Quantifying ecological novelty of vegetation through space–time comparisons

---

## 11. Summary & Invitation *(8:30–9:00)*

- VegVault bridges temporal and disciplinary gaps in vegetation science
- Enables robust ecological synthesis and forecasting
- Scalable, transparent, and open by design
- We welcome collaborations and encourage the community to contribute and explore

---

## 12. Final Slide: Contact & Resources *(9:00–9:30)*

- Website, ORCID, GitHub, Lab page
- Include QR codes and short URLs for quick access
- Acknowledge collaborators, funders, and data providers

---

## Buffer Time & Optional Slides *(~3 minutes for Q&A)*

- Optionally include one or more backup slides:
  - Full VegVault schema overview
  - SPROuT and SSoQE overview

