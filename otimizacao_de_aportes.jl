

#%%Packages
using JuMP, GLPK, DataFrames, XLSX, CSV, Ipopt

#%% Data
df = XLSX.readdata("G:/Meu Drive/Investimentos.xlsx", "Investimentos", "C1:M16")
df = DataFrame(Any[@view df[2:end, i] for i in 1:size(df, 2)], Symbol.(df[1, :]))

#Removing some columns
select!(df, Not([:Amount,:Average_price,:Range,:Diff,:Actual_value,:Invested]))

#%% Variables
investido = df.Profitable_investment
ideal = df.Ideal_allocation
conj_ativos = collect(1:(size(df)[1])) # qnt. de atributos
valor_aporte = 1000 #EM DÓLARES
vender = false

#%% Optimization
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

#%%Results
print("\nObjective function: ", fo, "\n")
print("To sell: ", vender, "\n")
print("Investment: \$ ", valor_aporte, "\n\n")

insertcols!(df, size(df)[2]+1, :Investment => round.(aportee, digits = 3))

df.Allocation = round.(new_fracc; digits = 3)
df.Diff_Allocation = round.(df.Ideal_allocation - df.Allocation, digits = 3)
insertcols!(df, 3, :Invested => round.(df.Profitable_investment + df.Investment, digits = 3))
# df.Profitable_investment = round.(df.Profitable_investment + df.Investment, digits = 3)
# insertcols!(df, 8, :Diff_New => round.(df.Ideal_allocation - df.Allocation, digits = 3))
print(df)

print("\Investment: ",sum(df.Investment))
print("\nInvested dollars: ",sum(df.Invested))
