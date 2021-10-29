
#----Pacote e carregamento dos dados
using JuMP, GLPK, DataFrames, XLSX, CSV, Ipopt


df = XLSX.readdata("G:/Meu Drive/Investimentos.xlsx", "Investimentos", "C1:M16")
df = DataFrame(Any[@view df[2:end, i] for i in 1:size(df, 2)], Symbol.(df[1, :]))

select!(df, Not([:Qnt,:PM,:Variacao,:Diff_Inv,:Atual,:Investido]))
# names(df)
#----Variáveis
investido = df.Real
ideal = df.Ideal
conj_ativos = collect(1:(size(df)[1])) # qnt. de atributos
valor_aporte = 1000 #EM DÓLARES
vender = false

#----Otimização
clearconsole()
function OPT_problem(investido,ideal,conj_ativos,valor_aporte, vender)
    @eval begin
    OPT = Model(Ipopt.Optimizer);
    set_silent(OPT) # O otimizador não imprime nada.

    #Definição das variáveis
    if vender == false
        @variable(OPT, aporte[i in conj_ativos] >= 0)
    else
        @variable(OPT, aporte[i in conj_ativos])
    end
    @variable(OPT, new_frac[i in conj_ativos] >= 0)
    @variable(OPT, abs_frac[i in conj_ativos] >= 0)
    # @variable(OPT, investir[i in conj_ativos], binary = true)

    #Restrições
    @constraint(OPT, new_frac_, sum(new_frac[i] for i in conj_ativos) == 1)
    @NLconstraint(OPT, frac_ideal[i in conj_ativos],
        (new_frac[i] * sum(investido[i]+aporte[i] for i in conj_ativos))
        <= (investido[i]+aporte[i]))
    @constraint(OPT, abs_1[i in conj_ativos], abs_frac[i] >= (ideal[i] - new_frac[i]))
    @constraint(OPT, abs_2[i in conj_ativos], abs_frac[i] >= -(ideal[i] - new_frac[i]))
    @constraint(OPT, new_frac_less_one[i in conj_ativos], new_frac[i] <= 1)
    @constraint(OPT, val_aporte, sum(aporte[i] for i in conj_ativos) == valor_aporte)
    @constraint(OPT, val_aporte_max[i in conj_ativos], aporte[i] <= valor_aporte)
    # @constraint(OPT, corretagem, sum(investir[i] for i in conj_ativos) <= 10)


    #Função objetivo
    @objective(OPT, Min, sum(abs_frac[i] for i in conj_ativos))
    # @objective(OPT, Min, sum(L[t] for t in T_L)/L_norm + α*sum(sum(s[j,t] for j in p) for t in T_B))

    optimize!(OPT)
    fo = JuMP.objective_value(OPT)
    aportee=[JuMP.value.(aporte)[CartesianIndex(i)] for i in 1:length(ideal)]
    new_fracc=[JuMP.value.(new_frac)[CartesianIndex(i)] for i in 1:length(ideal)]

end
end
OPT_problem(investido,ideal,conj_ativos,valor_aporte, vender)

print("\nFunção objetivo: ", fo, "\n")
print("Vender: ", vender, "\n")
print("Aporte: \$ ", valor_aporte, "\n\n")

insertcols!(df, size(df)[2]+1, :Aporte => round.(aportee, digits = 3))

df.Fatia = round.(new_fracc; digits = 3)
df.Diff_Fatia = round.(df.Ideal - df.Fatia, digits = 3)
insertcols!(df, 3, :Investido => round.(df.Real + df.Aporte, digits = 3))
# df.Real = round.(df.Real + df.Aporte, digits = 3)
# insertcols!(df, 8, :Diff_New => round.(df.Ideal - df.Fatia, digits = 3))
print(df)

print("\nAporte: ",sum(df.Aporte))
print("\nDólares Investidos: ",sum(df.Investido))
