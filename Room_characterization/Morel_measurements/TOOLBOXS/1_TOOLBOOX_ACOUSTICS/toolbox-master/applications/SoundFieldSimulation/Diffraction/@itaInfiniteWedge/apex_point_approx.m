function apx = apex_point_approx( obj, source_pos, receiver_pos, spatial_precision )
%apex_point_approx approximates the shortest path by a minimisation
%approach based on the Euclidean distance.
    if nargin < 4
        spatial_precision = 1e-3; % mm
    end

    ap_start = obj.location;
    ap_dir = obj.edge_direction;
    
    S_on_ap = orthogonal_projection( ap_start, ap_dir, source_pos ); % project the source to the edge
    S_t = norm( S_on_ap - ap_start ); % parametric distance along the aperture
    R_on_ap = orthogonal_projection( ap_start, ap_dir, receiver_pos ); % same as above but for receiver
    R_t = norm( R_on_ap - ap_start ); % same
    
    start_t = min( S_t, R_t ); %start the optimisation at whichever of the projected source/ receiver comes first on the aperture
    end_t = max( S_t, R_t ); %finish at the other
    opts_t = optimset( 'TolX', spatial_precision, 'TolFun', spatial_precision, 'FunValCheck', 'on' );
    t = fminbnd( @(t)total_path_distance( t, source_pos, receiver_pos, ap_start, ap_dir ), start_t, end_t, opts_t );
   
    apx = ap_start + t .* ap_dir; %using the optimised parameter, find the aperture position
end


function dist = total_path_distance( t, source_pos, receiver_pos, start, dir )
    P = start + ( t * dir ); % P = point on the edge
    dist = norm( P - source_pos ) + norm( receiver_pos - P ); % given point on aperture, source and receiver positions, calculate the distance traveled
end

function point_on_line = orthogonal_projection( line_point, line_dir, point )
    point_on_line = line_point + dot( point - line_point, line_dir ) / dot( line_dir, line_dir ) * line_dir;
end