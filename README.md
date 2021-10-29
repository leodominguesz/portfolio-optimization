# Portfolio Optimization

Otimização de portfólio, para comprar e vender ativos de acordo com a composição ideal desejada pelo gestor. A proposta é facilitar na hora de rebalancear a carteira, o quanto de cada ativo é necessário comprar ou vender, para atingir a composição ideal.
O código trabalha com situações onde não se deseja vender ativos também, porém, não aborda custos de corretagens quando o rebalanceamento exige a venda de ativos e, com isso, demanda de algumas negociações.

Problema de otimização:

- Conjuntos:
  - Ativos (conj_ativos);
- Variáveis:
  - Aporte (aporte);
  - Nova composição (new_frac);
  - Diferença entre o ideal e o desejado, de forma absoluta(abs_frac).
- Parâmetros:
  - Valor investido em cada ativo (investido);
  - Aporte a ser realizado (valor_aporte);
  - Composição ideal de cada ativo (ideal);
  
Função objetivo:

Minimizar a diferença entre o valor absoluto da composição ideal com a real

<img src="https://render.githubusercontent.com/render/math?math=\min{\sum_i^n{|ideal_i-new\_frac_i|}}">

Como não podemos inserior a função objetivo desta forma, criamos uma outra variável, que representa o valor absoluto da diferença. Desta forma, temos:

<img src="https://render.githubusercontent.com/render/math?math=\min{\sum_i^n{abs\_frac_i}}">
 
Sujeito a:

Somatório dos ativos tem que ser igual a um.

<img src="https://render.githubusercontent.com/render/math?math=\sum_i^n{new\_frac} = 1">

A nova composição do ativo no portfolio tem que ser menor do que tiver investido nele e o aportado. Restrição para limitar e evitar erros.

<img src="https://render.githubusercontent.com/render/math?math=(new\_frac_i \dot \sum_i^n{investido_i %2B aporte_i}) \le investido_i %2B aporte_i">

A nova variável que criamos, na função objetivo, precisa de restrições para atender as razões da sua criação:

<img src="https://render.githubusercontent.com/render/math?math=abs\_frac_i \ge ideal_i - new\_frac_i">
<img src="https://render.githubusercontent.com/render/math?math=abs\_frac_i \ge -(ideal_i - new\_frac_i)">

Restrição para limitar o teto da nova composição:

<img src="https://render.githubusercontent.com/render/math?math=new\_frac_i \le 1">

O valor dos aportes em cada ativo tem que ser igual ao parâmetro do aporte:

<img src="https://render.githubusercontent.com/render/math?math=\sum_i^n{aporte_i} = valor\_aporte">

Além disso, o aporte em cada ativo não pode ser maior que o parâmetro que está sendo aportado. Precisa ser feito o "teto de gastos":

<img src="https://render.githubusercontent.com/render/math?math=aporte_i \le valor\_aporte">


Resumo:

Função Objetivo: 

<img src="https://render.githubusercontent.com/render/math?math=\min{\sum_i^n{abs\_frac_i}}">

Sujeito a:  

<img src="https://render.githubusercontent.com/render/math?math=\sum_i^n{new\_frac} = 1">
<img src="https://render.githubusercontent.com/render/math?math=(new\_frac_i \dot \sum_i^n{investido_i %2B aporte_i}) \le investido_i %2B aporte_i">
<img src="https://render.githubusercontent.com/render/math?math=abs\_frac_i \ge ideal_i - new\_frac_i">
<img src="https://render.githubusercontent.com/render/math?math=abs\_frac_i \ge -(ideal_i - new\_frac_i)">
<img src="https://render.githubusercontent.com/render/math?math=new\_frac_i \le 1">
<img src="https://render.githubusercontent.com/render/math?math=\sum_i^n{aporte_i} = valor\_aporte">
<img src="https://render.githubusercontent.com/render/math?math=aporte_i \le valor\_aporte">
