* ==============================================================================
* 05_probit_dyn_cre_ci.do
* Projeto : Determinantes da Adesão ao PGS – Alinhamento Político
* ------------------------------------------------------------------------------
* OBJETIVO
*   Estima o Probit dinâmico RE com:
*     - Correlated Random Effects / Mundlak (CRE): médias no tempo das
*       covariáveis time-varying para controlar heterogeneidade não observada.
*     - Condição inicial: y_{i1} (Wooldridge, 2005) para corrigir o problema
*       de endogeneidade da condição inicial no modelo dinâmico.
*
* REFERÊNCIA
*   Wooldridge, J.M. (2005). Simple solutions to the initial conditions
*   problem in dynamic, nonlinear panel data models with unobserved
*   heterogeneity. Journal of Applied Econometrics, 20(1), 39–54.
*
* OUTPUT : ${dir_tables}/tab_ame_probit_dyn_cre_ci.tex
* ==============================================================================

do "${root}/config.do"

use "${bd_final}", clear
xtset id_municipio ano
keep if inrange(ano, ${ano_ini}, ${ano_fim})

* --- 1) Defasagem do desfecho -------------------------------------------------
gen y_l1 = L.ano_tratado
label variable y_l1 "Participou no ano anterior (t-1)"

* --- 2) Condição inicial: y_{i1} ----------------------------------------------
bysort id_municipio (ano): gen y_i1 = ano_tratado[1]
label variable y_i1 "Condição inicial: participou no 1º ano observado"

* --- 3) Médias no tempo (CRE / Mundlak) --------------------------------------
local covs dias_chuva_l1 aridez_evapo12_l1 alin_gov_fed alin_pref_fed ///
           pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1

foreach v of local covs {
    bysort id_municipio: egen mean_`v' = mean(`v')
    label variable mean_`v' "Média temporal: `v'"
}

* --- 4) Remover 1ª obs (lag indisponível) ------------------------------------
drop if missing(y_l1)

* --- 5) Estimação -------------------------------------------------------------
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

estimates store probit_dyn_cre_ci

* --- 6) AME -------------------------------------------------------------------
margins, dydx( ///
    y_l1 ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    alin_gov_fed alin_pref_fed ///
    pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1) post

estimates store AME_dyn_CRE_CI

* --- 7) Exportar tabela -------------------------------------------------------
esttab AME_dyn_CRE_CI using "${dir_tables}/tab_ame_probit_dyn_cre_ci.tex", ///
    replace booktabs label se ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    nonumber nomtitle ///
    stats(N, fmt(%9.0fc) labels("Observações")) ///
    title("AME – Probit Dinâmico RE + CRE + Condição Inicial\label{tab:probit_dyn_cre_ci}") ///
    addnotes("Efeitos marginais médios (AME). Erros-padrão clusterizados no município." ///
             "CRE/Mundlak: médias no tempo das covariáveis time-varying." ///
             "Condição inicial: y\$_{i1}\$ (Wooldridge, 2005).")

display as result "tab_ame_probit_dyn_cre_ci.tex exportada."
