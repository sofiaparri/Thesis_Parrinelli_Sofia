function varargout = ne(varargin)
%not equal

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

varargout{1} = ~eq(varargin{:});
end