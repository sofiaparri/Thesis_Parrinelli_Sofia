function alpha_iso = ita_atmospheric_absorption_iso9613( f, temperature, humidity, static_pressure )
	% ISO 9613-1 Acoustics - Attenuation of sound during propagation outdoors
    
	% Reference ambient atmospheric pressure (Standard Ambient Atmosphere) [kPa] 
	% (Referenzatmosph�rendruck Umgebung nach ISO Standard)
    
    ita_propagation_load_defaults
    default_values = ita_propagation_defaults;
    
    if nargin < 4
        static_pressure = default_values.static_pressure;
    end
    if nargin < 3
        humidity = default_values.humidity;
    end    
    if nargin < 2
        temperature = default_values.air.temperature;
    end    
    if nargin < 1
        error( 'Incorrect number of parameters supplied. Supported function calls: ita_atmospheric_absorption_iso9613( f ), ita_atmospheric_absorption_iso9613( f, temperature, humidity, pressure). In the first case, default values for the temperature, humidity and pressure are used )');
    end
    
	p_r = 101.325;

	% Ambient atmospheric pressure [kPa]
	p_a = static_pressure;

	% Reference air temperature [K]
	T_0 = 273.15 + 20.0;

	% Temperature [K] used for equation (B.3)
	T_01 = 273.15 + 0.01;

	% Ambient atmospheric temperature [K]
	T = 273.15 + temperature;

	% Equations (B.3) and (B.2) of Annex B used for calculation of h in (B.1)
	C = -6.8346 * ( T_01 / T ).^1.261 + 4.6151;
	p_sat_p_r = 10.0.^C;

	%Molar concentration of water vapour [%] (Molek�ldichte Wasserdampf)
	%Equation (B.2)
	%assert( 0.0f <= dHumidity && dHumidity <= 100.0f );
	h = humidity * p_sat_p_r / ( p_a / p_r );

	% Oxygen relaxation frequency [Hz]
	% Equation (3) 
	f_r_o = ( p_a / p_r ) * ( 24.0 + 4.04e4*h*( 0.02 + h ) / ( 0.391 + h ) );

	% Nitrogen relaxation frequency [Hz]
	% Equation (4)
	f_r_n = ( p_a / p_r ) * ( T / T_0).^(-1.0 / 2.0) * ( 9.0 + 280.0*h*exp( -4.710 * ( ( T / T_0).^( -( 1 / 3.0 ) ) - 1.0 ) ) );

	% Parts of Equation (5) for the calculation of the attenuation coefficient [dB/m]
	alpha1 = 8.686 .* f.^ 2.0;
	alpha2 = 1.84e-11 * ( p_a / p_r).^ -1.0 * ( T / T_0).^(1.0 / 2.0);
	alpha3 = ( T / T_0).^(-5.0 / 2.0);
	alpha4 = 0.01275 .* exp( -2239.1 / T ) .* ( f_r_o + ( f.^ 2.0 ) ./ f_r_o).^(-1.0);
	alpha5 = 0.10680 .* exp( -3352.0 / T ) .* ( f_r_n + ( f.^ 2.0 ) ./ f_r_n).^(-1.0);

	% Attenuation coefficient [dB/m], ~f, as assembly of Equation (5) parts
	alpha_iso = alpha1 .* ( alpha2 + alpha3 .* ( alpha4 + alpha5 ) );
    
end
