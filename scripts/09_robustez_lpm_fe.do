* ==============================================================================
* 09_robustez_lpm_fe.do
* Projeto : Determinantes da Adesão ao PGS – Alinhamento Político
* ------------------------------------------------------------------------------
* OBJETIVO
*   Robustez: Modelo Linear de Probabilidade (LPM) com efeitos fixos de
*   município e de ano, erros-padrão clusterizados no município.
*   Verifica também a qualidade do ajuste (acurácia, previsões fora de [0,1]).
*
* OUTPUT : ${dir_tables}/tab_lpm_fe.tex
* ==============================================================================

do "${root}/config.do"

use "${bd_final}", clear
xtset id_municipio ano
keep if inrange(ano, ${ano_ini}, ${ano_fim})

* --- Estimação: LPM-FE -------------------------------------------------------
reghdfe ano_tratado ///
    dias_chuva_l1 ///
    aridez_evapo12_l1 ///
    alin_gov_fed ///
    alin_pref_fed ///
    pib_admpub_sh_l1 ///
    pib_agro_sh_l1 ///
    ln_dens_pop_l1, ///
    absorb(id_municipio ano) vce(cluster id_municipio)

estimates store LPM_FE

* --- Exportar tabela ----------------------------------------------------------
esttab LPM_FE using "${dir_tables}/tab_lpm_fe.tex", ///
    replace booktabs label se ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    nonumber nomtitle ///
    stats(N r2_a, fmt(%9.0fc %9.3f) labels("Observações" "R² ajustado")) ///
    title("Robustez – LPM com Efeitos Fixos\label{tab:lpm_fe}") ///
    addnotes("Modelo linear de probabilidade com efeitos fixos de município e de ano." ///
             "Erros-padrão robustos clusterizados no município.")

display as result "tab_lpm_fe.tex exportada."

* --- Verificações do LPM -----------------------------------------------------
predict phat_fe if e(sample), xb

* Truncar previsões a [0, 1]
gen phat_fe01 = phat_fe if e(sample)
replace phat_fe01 = 0 if phat_fe01 < 0
replace phat_fe01 = 1 if phat_fe01 > 1

* Classificação binária (cutoff 0.5)
gen yhat_fe  = (phat_fe01 >= 0.5) if e(sample)
gen acerto   = (yhat_fe == ano_tratado) if e(sample)

qui summ acerto if e(sample)
display as result "Acurácia (cutoff 0.5) = " %6.4f r(mean)

qui count if phat_fe < 0 & e(sample)
display as result "Previsões < 0 : " r(N)

qui count if phat_fe > 1 & e(sample)
display as result "Previsões > 1 : " r(N)

drop phat_fe phat_fe01 yhat_fe acerto
