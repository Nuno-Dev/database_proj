SELECT s.ano,s.dia_semana,s.concelho, COUNT(s.ean) FROM sales AS s 
WHERE ano::decimal  BETWEEN 2005 AND 2022
GROUP BY CUBE(s.ano, s.dia_semana, s.concelho);

SELECT s.distrito,s.concelho,s.cat,s.dia_semana,COUNT(s.ean) FROM sales AS s 
WHERE s.distrito = 'setubal'
GROUP BY CUBE(s.distrito,s.concelho,s.cat,s.dia_semana);
