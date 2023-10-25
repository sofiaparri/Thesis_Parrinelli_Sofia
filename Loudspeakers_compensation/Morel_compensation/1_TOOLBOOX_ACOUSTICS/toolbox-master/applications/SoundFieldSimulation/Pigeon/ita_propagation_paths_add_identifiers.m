function [ pps_with_ids, pps_hash_table ] = ita_propagation_paths_add_identifiers( pps, verbose_hashing, use_clear_text )
%
% ita_propagation_paths_add_identifiers Adds identifiers to the propagation
% paths struct based on a hashing convention that takes surface and edge
% ids into account.
%%
% Example: pps_with_ids = ita_propagation_paths_add_identifiers( pps )
%          [ pps_with_ids, pps_hash_table ] = ita_propagation_paths_add_identifiers( pps, true ) % verbose output
%

if nargin < 2
    verbose_hashing = false;
end
if nargin < 3
    use_clear_text = false;
end

if ~isfield( pps, 'class' )
    error( 'Could not modify propagation path list, struct is missing field "class"' )
end

if ~isfield( pps, 'propagation_anchors' )
    error( 'Could not modify propagation path list, struct is missing field "propagation_anchors"' )
end

pps_with_ids = pps;
pps_hash_table = struct();

for n = 1:numel( pps )
    pp = pps( n );

    path_id_clear = '';
    for a = 1:numel( pp.propagation_anchors )
        
        if( isa( pp.propagation_anchors, 'struct' ) )
            anchor = pp.propagation_anchors( a );
        else
            anchor = pp.propagation_anchors{ a };
        end
        
        switch anchor.anchor_type
            case { 'source', 'emitter' }
                anchor_id_seg = strcat( 'S(', anchor.name, ')' );
            case { 'receiver', 'sensor' }
                anchor_id_seg = strcat( 'R(', anchor.name, ')' );
            case 'specular_reflection'
                anchor_id_seg = sprintf( 'SR(%i-%i)', a-1, anchor.polygon_id );
            case { 'outer_edge_diffraction', 'inner_edge_diffraction' }
                anchor_id_seg = sprintf( 'ED(%i-%i-%i)', a-1, anchor.main_wedge_face_id, anchor.opposite_wedge_face_id );
            otherwise
                error 'Unrecognized anchor type, could not generate unique id for this path sequence'
        end
        
        if a == 1
            path_id_clear = strcat( path_id_clear, anchor_id_seg );
        else
            path_id_clear = strcat( path_id_clear, ':', anchor_id_seg );
        end
        
    end
    
    assert( numel( path_id_clear ) > 0 )
    path_id_hashed = char( mlreportgen.utils.hash( path_id_clear ) );
    
    % store in output variables
    if use_clear_text
        pps_with_ids( n ).identifier = path_id_clear;
    else
        pps_with_ids( n ).identifier = strcat( 'hash', path_id_hashed ); % Put a non-numerical prefix to avoid indexing poblems
    end
    pps_hash_table( n ).key = path_id_clear;
    pps_hash_table( n ).hash = path_id_hashed;
    
    if verbose_hashing
        fprintf( '%s <= %s\n', path_id_hashed, path_id_clear )
    end

end

end
