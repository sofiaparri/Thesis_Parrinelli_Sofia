function [ linear_freq_data, valid ] = tf_diffraction( obj, anchor, effective_source_position, effective_receiver_position, diffraction_model )
%TF_REFLECTION Returns the specular reflection transfer function for a diffraction point to an effective receiver point with
% an incident and emitting direction

if nargin < 5
   diffraction_model = obj.diffraction_model;
end

if ~isfield( anchor, 'anchor_type' )
    error( 'The anchor argument does not contain a field "anchor_type"' )
end

valid = false;
linear_freq_data = ones( obj.num_bins, 1 );

% Assemble wedge
n1 = anchor.main_wedge_face_normal( 1:3 );
n2 = anchor.opposite_wedge_face_normal( 1:3 );
loc = anchor.vertex_start( 1:3 );
endPt = anchor.vertex_end( 1:3 );
len = norm( endPt - loc );
aperture_dir = ( endPt - loc ) / len;

% check if wedge is a screen
if ~strcmpi( diffraction_model, 'btms' )
    if abs( cross(n1, n2) ) < itaInfiniteWedge.set_get_geo_eps
        w = itaSemiInfinitePlane( n1, loc, aperture_dir );
    else
        w = itaInfiniteWedge( n1, n2, loc );
    end
else
    w = itaFiniteWedge( n1, n2, loc, len );
%     w.aperture_direction = aperture_dir;
%     w.aperture_end_point = endPt;
end

% Legacy
if size( effective_source_position, 1 ) == 4
    effective_source_position = effective_source_position( 1:3 )';
end
if size( effective_receiver_position, 1 ) == 4
    effective_receiver_position = effective_receiver_position( 1:3 )';
end

% Validate
apex_point = w.get_aperture_point_far_field( effective_source_position, effective_receiver_position );
if all( apex_point == effective_source_position  ) || ...
   all ( apex_point == effective_receiver_position )
    warning( 'Skipping a path segment with a double anchor point' )
    return
elseif any( isnan( apex_point ) )
    warning( 'Skipping a path segment with an invalid aperture point' )
    return
end

% Return only the diffraction component and the subsequent
% sphere-cylinder-shaped wave spreading loss factor to next effective
% receiver (ignore effective source pos)
switch( diffraction_model )
    case 'utd'
        
        % With or without spreading loss after diffraction
        linear_freq_data = obj.tf_diffraction_utd( w, effective_source_position, effective_receiver_position );
        
    case 'maekawa'
        
        linear_freq_data = obj.tf_diffraction_maekawa( w, effective_source_position, effective_receiver_position );
        
    case 'btms'
        
        btms_ir = obj.tf_diffraction_btms( w, effective_source_position( 1:3 )', effective_receiver_position( 1:3 )' );
        diffraction_dft = fft( btms_ir, obj.num_bins * 2 - 1 ); % odd DFT spectrum
        diffraction_hdft = diffraction_dft( 1:ceil( obj.num_bins ) );
        
        eff_source_distance = norm( apex_point - effective_source_position );
        spreading_loss = ita_propagation_spreading_loss( eff_source_distance );
        phase_delay_after_diffr = obj.phase_delay( eff_source_distance );
        
        normilization_tf = spreading_loss * phase_delay_after_diffr;
        
        linear_freq_data = diffraction_hdft ./ normilization_tf;
        
    otherwise
        
        warnning 'Unknown diffraction model, returning neutral transfer function'
    
end

valid = true;

end

