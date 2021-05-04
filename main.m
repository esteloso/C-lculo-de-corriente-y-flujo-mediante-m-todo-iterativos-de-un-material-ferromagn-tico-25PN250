clc;
clear all;
close all;

%%Datos del problema

lg=2e-3; %Longitud del entrehierro
x=0.2; % Largo y ancho del material ferromagnético
p=50e-3; %Profundidad y dimensiones del area transversal del material
fa=0.95; %Factor de apilamiento
n=500; %Numero de vueltas en la bobina
phi=4e-3; %Flujo magnético deseado
I=10; %Corriente en la bobina deseada
u0=1.256637061e-6; %permeabilidad magnética en el vacio/entrehierro

%Importar los datos para la interpolación por Luis Leon
Material='35PN250'; %Nombre de los archivos txt
datos=importdata([Material,'.txt']);


fprintf(['Calculando la corriente para un flujo en el material de: ', num2str(phi),' Wb  \n']);
%Calculos previos a la interpolación
Ae=fa*p^2; %Area efectiva del material ferromagnético
Ag=(p+lg)^2; %Area efectiva del entrehierro
lm=4*(x-p)-lg; %Longitud media del material ferromagnético

Bm=phi/Ae; %Densidad de flujo en el material ferromagnético
Bg=phi/Ag; %Densidad de flujo en el entrehierro

%Plot de las curvas de magnetización interpoladas
Bi=linspace(0,2,1000);
H=interp1(datos(:,2),datos(:,1),Bi,'spline','extrap');
figure;
plot(H,Bi);
xlim([0,max(H)]);
ylim([0,max(Bi)]);
title(['Curva de magnetización para el material: ',Material])

%PRIMERA PARTE 

%Interpolación de los datos B-H para obtener la intensidad de campo
%magnético en el material y el entrehierro, los valores de Hm y Hg se 
%encuentran en las columnas para cada material.

 Hm=interp1(datos(:,2),datos(:,1),Bm,'spline','extrap');


%Cálculo de las corrientes

I_x=(Hm*lm+(Bg/u0)*lg)/n; %Corriente en la bobina

fprintf(['La corriente en la bobina, para el material ', Material,' debe ser de: ', num2str(I_x), ' A \n'])


%SEGUNDA PARTE:

%Definición de la recta de carga

syms B(h);
B(h)=(n*I-h*lm)*(u0*Ag)/(lg*Ae); %Recta de carga

err=0.0001; %limite aceptable del error
e=[1]; %error
hmax=max(H); %valor final
hx=min(H); %valor inicial

disp('...')
fprintf(['Calculando el flujo magnético para una corriente de : ', num2str(I),' A  \n']);
while ((e(end)>err) && (hx<hmax))
    B1=B(hx); %campo segun la recta de carga
    B1=eval(B1);

    B2=interp1(datos(:,1),datos(:,2),hx,'spline'); %calculo segun la curva de magnetización

    e=[e,abs((B1-B2))]; %calculo del error
    hx=hx+10*e(end); %el cambio es dinámico, el 10 es para acelerar el descenso
end

%Plot de la gráfica de error
figure;
plot(e);
ylim([0,1])
title('Error absoluto en el cálculo por iteración')

%Cálculo del flujo magnético
Bx=(B1+B2)/2; %Densidad de campo obtenida por la iteración
hx; %Intensidad del campo magnético, obtenida por iteración.

phi_x=Bx*Ae; %flujo mágnetico a traves del material ferromagnético

fprintf(['El flujo en el material ferromagnético ', Material,' debe ser de: ', num2str(phi_x), ' Wb \n'])
fprintf(['El error basoluto del cálculo fue de: ', num2str(e(end))])






