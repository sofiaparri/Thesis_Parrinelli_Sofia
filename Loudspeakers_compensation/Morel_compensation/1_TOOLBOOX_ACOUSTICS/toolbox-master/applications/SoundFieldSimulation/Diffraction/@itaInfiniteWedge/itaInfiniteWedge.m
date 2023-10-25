classdef itaInfiniteWedge
    
    properties (Access = protected)
        n1 % 3-dim normal vector of main face (internal)
        n2 % 3-dim normal vector of opposite face (internal)
        ed % 3-dim edge direction vector (internal)
        l % Internal location variable
        et % type of edge (internal)
        bc_hard % Internal boundary condition (hard = true)
    end
    
    properties (Dependent)
        main_face_normal % 3-dim normal vector of main face (normalized)
        opposite_face_normal % 3-dim normal vector of opposite face (normalized)
        aperture_direction % 3-dim normal vector of aperture direction (normalized) LEGACY
        edge_direction % 3-dim normal vector of edge direction (normalized)
        location % Location of wedge (somewhere along edge)
        opening_angle % Angle from main to opposite face in propagation medium / air (radiants)
        wedge_angle % Angle from main to opposite face in solid medium of wedge (radiants)
        edge_type % 'wedge' for opening angles > pi or 'corner' for opening angles < pi
        boundary_condition % boundary condition of the wedge faces (hard or soft)
    end
    
    methods
        function obj = itaInfiniteWedge( main_face_normal, opposite_face_normal, location, edge_type, edge_direction )
            % Create a wedge by a main face normal and an opposite face
            % normal
            %   main_face_normal:       Main face normal (3-dim)
            %   opposite_face_normal:   Opposite face normal (3-dim)
            %   location:               Point on edge which defines
            %                           location of the wedge in 3_dim sapce
            %   edge_type:              use 'outer_edge' for opening angles > pi (default) and
            %                           'inner_edge' for opening angles < pi
            %   edge_direction          Edge direction vector (3-dim)
            % Note: 3-dim direction vectors will be normalized automatically
            % 
            if nargin < 4
                edge_type = 'outer_edge';
            end
            if ~isequal( edge_type, 'inner_edge' ) && ~isequal( edge_type, 'outer_edge' )
                error( 'Invalid edge type. Use either ''inner_edge'' or ''outer_edge''' )
            end
            if numel( main_face_normal ) ~= 3
                error 'Main face normal has to be a 3-dim vector'
            end
            if numel( opposite_face_normal ) ~= 3
                error 'Opposite face normal has to be a 3-dim vector'
            end
            if numel(location) ~= 3
                error( 'Location must be of dimension 3')
            end
            
            obj.n1 = main_face_normal;
            obj.n2 = opposite_face_normal;
            obj.l = location;
            obj.et = edge_type;
            obj.bc_hard = true;
            
            if ~obj.validate_normals
                warning 'Normalized face normals'
                obj.n1 = main_face_normal ./ norm( main_face_normal );
                obj.n2 = opposite_face_normal ./ norm( opposite_face_normal );
            end
            
            if nargin < 5
                n_scaled = cross( obj.main_face_normal, obj.opposite_face_normal );
                if ~norm( n_scaled )
                    warning 'Normals are linear dependent and edge direction could not be determined. Please set edge direction manually.'
                else
                    obj.ed = n_scaled ./ norm( n_scaled );
                end
            else
                obj.ed = edge_direction;
            end
        end
        
        function n = get.main_face_normal( obj )
            n = obj.n1;
        end
                
        function n = get.opposite_face_normal( obj )
            n = obj.n2;
        end
        
        function n = get.edge_direction( obj )
            % Returns normalized direction of edge. Vectors main face normal, opposite face normal and edge direction 
            % form a clockwise system.
            if isempty( obj.ed )
                error 'Invalid wedge, edge direction not set and face normals are linear dependent'
            end
            n = obj.ed;
        end
        
        function obj = set.edge_direction( obj, edge_direction )
            % Sets edge direction manually (in case of linear
            % dependent normals)
            if norm( cross( obj.n1, obj.n2 ) )
                error 'Edge of linear independent normals is fixed can not be modified'
            end
            if ~norm( edge_direction )
                error 'Edge vector must be a valid direction'
            end
            if norm( edge_direction ) ~= 1
                warning ' Normalizing edge direction'
                edge_direction = edge_direction / norm( edge_direction );
            end
            if ~( dot( edge_direction, obj.n1 ) == 0 && dot( edge_direction, obj.n2 ) == 0 )
                error 'Invalid edge direction, vector must be perpendicular to face normals'
            end
            obj.ed = edge_direction;
        end
        
        function beta = get.wedge_angle( obj )
            % Returns angle from main to opposite face through solid medium
            % of the wedge (radiant)
            if isequal( obj.et, 'outer_edge' )
                s = 1;
            elseif isequal( obj.et, 'inner_edge' )
                s = -1;
            end
            beta = pi - s * acos(dot(obj.main_face_normal, obj.opposite_face_normal));
        end
        
        function beta_deg = wedge_angle_deg( obj )
            % Get the wedge angle angle in degree
            beta_deg = rad2deg( obj.wedge_angle );
        end  
        
        function theta = get.opening_angle( obj )
            % Returns angle from main face to opposite face through propagation medium /
            % air (radiant)
            theta = 2 * pi - obj.wedge_angle;
        end
                
        function theta_deg = opening_angle_deg( obj )
            % Get the wedge opening angle in degree
            theta_deg = rad2deg( obj.opening_angle );
        end
        
        function l = get.location( obj )
            l = obj.l;
        end
        
        function obj =  set.location( obj, location )
            if numel( location ) ~= 3
                error( 'Location must be of dimension 3')
            end
            obj.l = location;
        end
        
        function b = validate_normals( obj )
            % Returns true, if the normals of the faces are both normalized
            b = false;
            if ( norm( obj.main_face_normal ) - 1 ) < eps && ( norm( obj.opposite_face_normal ) -1 ) < eps
               b = true;
            end
        end
        
        function et = wedge_type( obj )
            et = obj.edge_type;
            warning 'Function ''wedge_type'' is deprecated, use ''edge_type'' instead.'
        end
        
        function et = get.edge_type( obj )
            et = obj.et;
        end
        
        function bc = get.boundary_condition( obj )
            if obj.bc_hard
                bc = 'hard';
            else
                bc = 'soft';
            end
        end
                
        function obj = set.boundary_condition( obj, bc )
            if ischar(bc)
                if strcmpi('hard', bc)
                    obj.bc_hard = true;
                elseif strcmpi('soft', bc)
                    obj.bc_hard = false;
                else
                    error('boundary condition must be "hard" or "soft"!');
                end
            else
                error('boundary condtion must be of type character!');
            end
        end
        
        function obj = set.bc_hard( obj, b )
            obj.bc_hard = b;
        end
        
        function bc = is_boundary_condition_hard( obj )
            bc = obj.bc_hard;
        end
        
        function bc = is_boundary_condition_soft( obj )
            bc = ~obj.bc_hard;
        end
        
        % Legacy support (before renaming aperture to apex)
        
        function apx = approx_aperture_point( obj, source_pos, receiver_pos, varargin )
            if nargin == 3
                apx = obj.apex_point_approx( source_pos, receiver_pos );
            else
                spatial_precision = varargin;
                apx = obj.apex_point_approx( source_pos, receiver_pos, spatial_precision );
            end
        end
        
        function ap = get_aperture_point_far_field( obj, source_pos, receiver_pos )
            ap = obj.apex_point( source_pos, receiver_pos );
        end
        
        function b = point_on_aperture( obj, point )
            b = obj.point_on_edge( point );
        end
        
        function alpha_rad = get_angle_from_point_to_aperture( obj, field_point, point_on_edge )
            alpha_rad = obj.get_angle_from_point_to_apex( field_point, point_on_edge );
        end
                
        function ap = get_aperture_point( obj, source_pos, receiver_pos )
            ap = obj.apex_point( source_pos, receiver_pos );
        end
        
        function n = get.aperture_direction( obj )
            n = obj.edge_direction;
        end
        
        function obj = set.aperture_direction( obj, edge_direction_ )
            obj.edge_direction = edge_direction_;
        end
        
    end
    
    
    methods (Static)
        function current_eps = set_get_geo_eps( new_eps )
            % Controls and returns the geometrical calculation precision value for
            % deciding e.g. if a point is inside or outside a wedge
            % (defaults to Matlab eps, but should be set for instance to
            % millimeter (1e-3) or micrometer (1e-6).
            persistent geo_eps;
            if nargin > 0
                geo_eps = new_eps;
            end
            if isempty( geo_eps )
                geo_eps = eps; % Default eps from Matlab double precision
            end
            current_eps = geo_eps;
        end
    end
end