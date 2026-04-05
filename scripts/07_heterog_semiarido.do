* ==============================================================================
* 07_heterog_semiarido.do
* Projeto : Determinantes da Adesão ao PGS – Alinhamento Político
* ------------------------------------------------------------------------------
* OBJETIVO
*   Heterogeneidade geográfica – municípios do Semiárido (semiarido == 1).
*   Especificação: Probit dinâmico RE + CRE/Mundlak + condição inicial.
*
* OUTPUT : ${dir_tables}/tab_ame_probit_dyn_cre_ci_semiarido.tex
* ==============================================================================

do "${root}/config.do"

use "${bd_final}", clear
xtset id_municipio ano
keep if inrange(ano, ${ano_ini}, ${ano_fim})
keep if semiarido == 1

* --- Componentes dinâmicos e CRE ---------------------------------------------
gen y_l1 = L.ano_tratado
label variable y_l1 "Participou no ano anterior (t-1)"

bysort id_municipio (ano): gen y_i1 = ano_tratado[1]
label variable y_i1 "Condição inicial"

local covs dias_chuva_l1 aridez_evapo12_l1 alin_gov_fed alin_pref_fed ///
           pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1
foreach v of local covs {
    bysort id_municipio: egen mean_`v' = mean(`v')
}

drop if missing(y_l1)

* --- Estimação ---------------------------------------------------------------
xtprobit ano_tratado ///
    y_l1 ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    alin_gov_fed alin_pref_fed ///
    pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1 ///
    y_i1 ///
    mean_dias_chuva_l1 mean_aridez_evapo12_l1 ///
    mean_alin_gov_fed mean_alin_pref_fed ///
    mean_pib_admpub_sh_l1 mean_pib_agro_sh_l1 mean_ln_dens_pop_l1 ///
    i.ano, re vce(cluster id_municipio)

estimates store probit_dyn_cre_ci_semi

* --- AME ---------------------------------------------------------------------
margins, dydx( ///
    y_l1 ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    alin_gov_fed alin_pref_fed ///
    pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1) post

estimates store AME_dyn_CRE_CI_semi

* --- Exportar tabela ---------------------------------------------------------
esttab AME_dyn_CRE_CI_semi using "${dir_tables}/tab_ame_probit_dyn_cre_ci_semiarido.tex", ///
    replace booktabs label se ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    nonumber nomtitle ///
    stats(N, fmt(%9.0fc) labels("Observações")) ///
    title("AME – Semiárido (Wooldridge 2005)\label{tab:heterog_semi}") ///
    addnotes("Amostra restrita a municípios do Semiárido (semiarido==1)." ///
             "Efeitos marginais médios (AME). Erros-padrão clusterizados no município.")

display as result "tab_ame_probit_dyn_cre_ci_semiarido.tex exportada."
