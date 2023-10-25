function [ data, samplerate, metadata ] = dfRavenBinauralVA_jst( alpha, beta, rpf )
% dfRavenBinauralVA_jst Implementation by JST using built-in functions of
% itaCoordinates and transforms to OpenGL with ita_matlab2openGL instead
%
% Generates an BRIR dataset (substitute for an HRIR) for VirtualAcoustics
% using RAVEN simulations.
%

    view = itaCoordinates( 1 );
    view.phi = alpha;
    view.theta_deg = 180 - beta;
    view.r = 1.0;
    
    up = view;
    up.theta = view.theta - pi/2;
        
    rpf.setReceiverViewVectors( ita_matlab2openGL( view.cart ) );
    rpf.setReceiverUpVectors( ita_matlab2openGL( up.cart ) );

    rpf.run();
    brir = rpf.getBinauralImpulseResponseImageSourcesItaAudio;  % only early reflections are requested, use rpf.getBinauralImpulseResponseItaAudio if you want to get the full impulse response (and adjust the filter length in your rpf accordingly)
    
    n_residual = mod( brir.nSamples, 4 );
    data = [ brir.timeData', zeros( brir.nChannels, n_residual ) ];
    
    samplerate = brir.samplingRate;
    metadata = [];
    
end
