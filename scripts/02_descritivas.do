* ==============================================================================
* 02_descritivas.do
* Projeto : Determinantes da Adesão ao PGS – Alinhamento Político
* ------------------------------------------------------------------------------
* OBJETIVO
*   Gera tabela de estatísticas descritivas na amostra efetiva do modelo
*   principal (obs usadas na estimação do LPM-FE como referência de amostra).
*
* OUTPUT : ${dir_tables}/tab_descritivas.tex
* ==============================================================================

do "${root}/config.do"

use "${bd_final}", clear
xtset id_municipio ano
keep if inrange(ano, ${ano_ini}, ${ano_fim})

* --- Amostra de referência: LPM-FE -------------------------------------------
qui reghdfe ano_tratado ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    alin_gov_fed alin_pref_fed ///
    pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1, ///
    absorb(id_municipio ano) vce(cluster id_municipio)

* --- Descritivas na amostra efetiva ------------------------------------------
estpost summarize ///
    ano_tratado benef ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    alin_gov_fed alin_pref_fed ///
    alin_pref_pres_colig alin_gov_pres_colig alin_pref_gov_part ///
    pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1 ///
    if e(sample)

esttab using "${dir_tables}/tab_descritivas.tex", ///
    cells("count(fmt(%9.0fc)) mean(fmt(%9.3f)) sd(fmt(%9.3f)) min(fmt(%9.3f)) max(fmt(%9.3f))") ///
    collabels("N" "Média" "Desvio padrão" "Mínimo" "Máximo") ///
    label nonumber nomtitle replace booktabs ///
    title("Estatísticas Descritivas\label{tab:descritivas}") ///
    addnotes("Amostra restrita ao período ${ano_ini}--${ano_fim}.")

display as result "tab_descritivas.tex exportada."
